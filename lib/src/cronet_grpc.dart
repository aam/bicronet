library cronet_grpc;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:http2/http2.dart' as http2;
import 'package:grpc/grpc_connection_interface.dart' as grpc;

import 'third_party/cronet/generated_bindings.dart' as cronet;
import 'third_party/cronet_dart/generated_bindings.dart';

T throwIfNullptr<T>(T value) {
  if (value == ffi.nullptr) {
    print('throwIfNullptr failed at ${StackTrace.current}');
    throw Exception("Unexpected cronet failure: got null");
  }
  return value;
}

void throwIfFailed<T>(T result) {
  if (result != cronet.Cronet_RESULT.Cronet_RESULT_SUCCESS) {
    print('throwIfFailed failed at ${StackTrace.current}');
    throw Exception("Unexpected cronet failure: $result");
  }
}

// Owns ffi Cronet engine
class CronetEngine {
  CronetEngine(this._options, String userAgent) {
    final extension = Platform.isMacOS ? "dylib" : "so";
    ffiCronet = cronet.Cronet(ffi.DynamicLibrary.open(
        '.dart_tool/out/libcronet.103.0.5019.0.${extension}'));
    ffiCronetDart = CronetDart(ffi.DynamicLibrary.open(
        '.dart_tool/out/libcronet_dart.${extension}'));

    ffiEngine = throwIfNullptr(ffiCronet.Cronet_Engine_Create());

    final engineParams = throwIfNullptr(ffiCronet.Cronet_EngineParams_Create());
    print('userAgent: $userAgent');
    ffiCronet.Cronet_EngineParams_user_agent_set(engineParams,
        userAgent.toNativeUtf8().cast<ffi.Int8>());
    // ffiCronet.Cronet_EngineParams_enable_quic_set(engineParams, true);
    ffiCronet.Cronet_EngineParams_enable_http2_set(engineParams, true);

    throwIfFailed(ffiCronet.Cronet_Engine_StartWithParams(ffiEngine,
        engineParams));
    ffiCronet.Cronet_EngineParams_Destroy(engineParams);

    ffiCronet.Cronet_Engine_StartNetLogToFile(ffiEngine, 'mynetlog.json'.toNativeUtf8().cast<ffi.Int8>(), true);
    print('Started netlogging to mynetlog.json...');

    ffiCronetDart.InitDartApiDL(ffi.NativeApi.initializeApiDLData);
    ffiCronetDart.InitCronetDartApi(
      ffiCronet.addresses.Cronet_Engine_Shutdown.cast(),
      ffiCronet.addresses.Cronet_Engine_Destroy.cast(),
      ffiCronet.addresses.Cronet_Buffer_Create.cast(),
      ffiCronet.addresses.Cronet_Buffer_InitWithAlloc.cast(),
      ffiCronet.addresses.Cronet_UrlResponseInfo_http_status_code_get.cast(),
      ffiCronet.addresses.Cronet_Error_message_get.cast(),
      ffiCronet.addresses.Cronet_UrlResponseInfo_http_status_text_get.cast(),
      ffiCronet.addresses.Cronet_UploadDataProvider_GetClientContext.cast(),
      ffiCronet.addresses.Cronet_Executor_CreateWith.cast(),
      ffiCronet.addresses.Cronet_Executor_SetClientContext.cast(),
      ffiCronet.addresses.Cronet_Executor_GetClientContext.cast(),
      ffiCronet.addresses.Cronet_Executor_Destroy.cast(),
      ffiCronet.addresses.Cronet_Runnable_Run.cast(),
      ffiCronet.addresses.Cronet_Runnable_Destroy.cast());
  }

  CronetGrpcTransportStream startBidirectionalStream(Uri uri) {
    return CronetGrpcTransportStream(uri, this);
  }

  final grpc.ChannelOptions _options;

  late final cronet.Cronet ffiCronet;
  late final CronetDart ffiCronetDart;
  late final ffi.Pointer<cronet.Cronet_Engine> ffiEngine;
}

class StreamData {
  final Uint8List data;
  final bool isEndOfStream;
  StreamData(this.data, {required this.isEndOfStream});
}

class CallbackHandler {
  CallbackHandler(this.cronetEngine, this.executor, this.receivePort, this.dataToUpload);

  void listen(ffi.Pointer<cronet.Cronet_UrlRequest> request) {
    receivePort.listen((dynamic message) {
      print('CallbackHandler.listen $message');
      final list = message as List;
      final method = list[0] as String;
      final arguments = list[1].buffer.asUint64List();
      switch (method) {
        case "OnRedirectReceived": OnRedirectReceived(arguments); break;
        case "OnResponseStarted": OnResponseStarted(request, arguments); break;
        case "OnReadCompleted": OnReadCompleted(arguments); break;
        case "OnSucceeded": OnSucceeded(request, arguments); break;
        case "OnFailed": OnFailed(request, arguments); break;
        case "OnCanceled": OnCanceled(arguments); break;
        // ---
        case "Read": DoRead(arguments); break;
        case "Rewind": DoRewind(arguments); break;
        case "Close": DoClose(arguments); break;
      }
    }, onError: (error, stackTrace) {
      print('CallbackHandler error $error $stackTrace');
    });
  }

  void OnRedirectReceived(Uint64List arguments) {
    print('OnRedirectReceived $arguments');

  }

  void OnResponseStarted(ffi.Pointer<cronet.Cronet_UrlRequest> request,
                         Uint64List arguments) {
    print('OnResponseStarted $arguments');
    int responseCode = arguments[0];
    if (responseCode < 100 || responseCode > 299) {
      final ffi.Pointer<Utf8> errorMessage = ffi.Pointer.fromAddress(arguments[3]);
      if (errorMessage == ffi.nullptr) {
        incomingStreamController.addError(Exception(
            'Http exception code $responseCode'));
      } else {
        final errorMessageString = errorMessage.toDartString();
        malloc.free(errorMessage);
        incomingStreamController.addError(Exception(errorMessageString));
      }
      cronetEngine.ffiCronet.Cronet_UrlRequest_Cancel(request);
      return;
    }
    final responseInfo = ffi.Pointer.fromAddress(arguments[1]).cast<cronet.Cronet_UrlResponseInfo>();
    print('total bytes in response info: ${cronetEngine.ffiCronet.Cronet_UrlResponseInfo_received_byte_count_get(responseInfo)}');
    final headersCount = cronetEngine.ffiCronet.Cronet_UrlResponseInfo_all_headers_list_size(responseInfo);
    print('got $headersCount headers');
    final headers = <http2.Header>[];
    for (int i = 0; i < headersCount; i++) {
      final header = cronetEngine.ffiCronet.Cronet_UrlResponseInfo_all_headers_list_at(responseInfo, i);
      final name = cronetEngine.ffiCronet.Cronet_HttpHeader_name_get(header).cast<Utf8>().toDartString();
      final value = cronetEngine.ffiCronet.Cronet_HttpHeader_value_get(header).cast<Utf8>().toDartString();
      print("$i $header $name=$value");
      headers.add(http2.Header(name.codeUnits, value.codeUnits));
    }
    incomingStreamController.add(http2.HeadersStreamMessage(headers));

    print('Issuing UrlRequest_Read');
    final buffer = ffi.Pointer.fromAddress(arguments[2])
        .cast<cronet.Cronet_Buffer>();
    throwIfFailed(cronetEngine.ffiCronet.Cronet_UrlRequest_Read(
        request, buffer));
  }
  void OnReadCompleted(Uint64List arguments) {
    final request = ffi.Pointer<cronet.Cronet_UrlRequest>.fromAddress(arguments[0]);
    int responseCode = arguments[2];
    final buffer = ffi.Pointer<cronet.Cronet_Buffer>.fromAddress(arguments[3]);
    final bytesRead = arguments[4];
    final ffi.Pointer<Utf8> errorMessage = ffi.Pointer.fromAddress(arguments[5]);
    print('OnReadCompleted $arguments, bytesRead: $bytesRead');

    if (responseCode < 100 || responseCode > 299) {
      if (errorMessage == ffi.nullptr) {
        incomingStreamController.addError(Exception(
            'Http exception code $responseCode'));
      } else {
        final errorMessageString = errorMessage.toDartString();
        malloc.free(errorMessage);
        incomingStreamController.addError(Exception(errorMessageString));
      }
      cronetEngine.ffiCronet.Cronet_UrlRequest_Cancel(request);
      return;
    }

    final data = Uint8List.fromList(cronetEngine.ffiCronet.Cronet_Buffer_GetData(buffer).cast<ffi.Uint8>().asTypedList(bytesRead));
    print('OnReadCompleted data: $data');
    incomingStreamController.add(http2.DataStreamMessage(data, endStream: false));

    print('OnReadCompleted issuing another follow-up Read');
    final result = cronetEngine.ffiCronet.Cronet_UrlRequest_Read(request, buffer);
    if (result != cronet.Cronet_RESULT.Cronet_RESULT_SUCCESS) {
      receivePort.close();
      cronetEngine.ffiCronetDart.RemoveRequest(request.cast());
      incomingStreamController.addError(Exception("UrlRequest error $result"));
      incomingStreamController.close();
    }
  }
  void OnSucceeded(ffi.Pointer<cronet.Cronet_UrlRequest> request,
                   Uint64List arguments) {
    print('OnSucceeded $arguments');
    final responseInfo = ffi.Pointer.fromAddress(arguments[1]).cast<cronet.Cronet_UrlResponseInfo>();
    print('total bytes in response info: ${cronetEngine.ffiCronet.Cronet_UrlResponseInfo_received_byte_count_get(responseInfo)}');
    final headersCount = cronetEngine.ffiCronet.Cronet_UrlResponseInfo_all_headers_list_size(responseInfo);
    print('got $headersCount headers');
    final headers = <http2.Header>[http2.Header("grpc-status".codeUnits, "0".codeUnits)];
    // for (int i = 0; i < headersCount; i++) {
    //   final header = cronetEngine.ffiCronet.Cronet_UrlResponseInfo_all_headers_list_at(responseInfo, i);
    //   final name = cronetEngine.ffiCronet.Cronet_HttpHeader_name_get(header).cast<Utf8>().toDartString();
    //   final value = cronetEngine.ffiCronet.Cronet_HttpHeader_value_get(header).cast<Utf8>().toDartString();
    //   print("$i $header $name=$value");
    //   headers.add(http2.Header(name.codeUnits, value.codeUnits));
    // }
    incomingStreamController.add(http2.HeadersStreamMessage(headers, endStream: true));

    receivePort.close();
    cronetEngine.ffiCronetDart.RemoveRequest(request.cast());

    // cleanUpClient();

    // incomingStreamController.add(http2.DataStreamMessage(Uint8List(0), endStream: true));

    incomingStreamController.close();
    cronetEngine.ffiCronet.Cronet_UrlRequest_Destroy(request);
  }
  void OnFailed(ffi.Pointer<cronet.Cronet_UrlRequest> request, Uint64List arguments) {
    final errorPointer = ffi.Pointer.fromAddress(arguments[0]).cast<Utf8>();
    final error = errorPointer.toDartString();
    print('onFailed: $error');
    malloc.free(errorPointer);

    receivePort.close();
    cronetEngine.ffiCronetDart.RemoveRequest(request.cast());
    // cleanUpClient();

    incomingStreamController.addError(Exception(error));
    incomingStreamController.close();
    // _controller.addError(HttpException(error));
    // _controller.close();
    cronetEngine.ffiCronet.Cronet_UrlRequest_Destroy(request);

    cronetEngine.ffiCronet.Cronet_Engine_StopNetLog(cronetEngine.ffiEngine);
    print('Stopped netloggin.');
  }
  void OnCanceled(Uint64List arguments) {
    print('OnCancelled $arguments');
  }

  void DoRead(Uint64List arguments) {
    print('DoRead $arguments');
    final ffi.Pointer<cronet.Cronet_UploadDataSink> uploadDataSink =
        ffi.Pointer.fromAddress(arguments[0]);
    final ffi.Pointer<cronet.Cronet_Buffer> buffer = ffi.Pointer.fromAddress(arguments[1]);

    final cronetBufferSize = cronetEngine.ffiCronet.Cronet_Buffer_GetSize(buffer);
    final remaining = dataToUpload.length - bytesSent;
    final bytesNowToSend = cronetBufferSize > remaining? remaining : cronetBufferSize;
    final cronetBuffer = cronetEngine.ffiCronet.Cronet_Buffer_GetData(buffer).cast<ffi.Uint8>();
    print('cronetBufferSize: $cronetBufferSize');
    print('remaining: $remaining');
    print('bytesNowToSend: $bytesNowToSend');
    print('cronetBuffer: $cronetBuffer');
    int i = 0;
    for (final b in dataToUpload.getRange(bytesSent, bytesNowToSend)) {
      print('copying $i element $b');
      cronetBuffer[i++] = b;
      bytesSent++;
    }
    print('copying is done');
    cronetEngine.ffiCronet.Cronet_UploadDataSink_OnReadSucceeded(
        uploadDataSink.cast(), bytesNowToSend, /*final_chunk=*/false);
  }
  void DoRewind(Uint64List arguments) {
    print('DoRewind $arguments');
    // bytesSent = 0;
    final ffi.Pointer<cronet.Cronet_UploadDataSink> uploadDataSink =
        ffi.Pointer.fromAddress(arguments[0]);
    cronetEngine.ffiCronet.Cronet_UploadDataSink_OnRewindSucceeded(uploadDataSink);
  }
  void DoClose(Uint64List arguments) {
    print('DoClose $arguments');
    cronetEngine.ffiCronetDart.UploadDataProviderDestroy(
        ffi.Pointer.fromAddress(arguments[0])); 
  }

  final CronetEngine cronetEngine;
  final ReceivePort receivePort;
  final ffi.Pointer<CronetTaskExecutor> executor;
  final incomingStreamController = StreamController<http2.StreamMessage>();

  final dataToUpload;
  int bytesSent = 0;
}

// Owns ffi Cronet bidirectional stream
class CronetGrpcTransportStream implements grpc.GrpcTransportStream {
  final incomingStreamController = StreamController<grpc.GrpcMessage>();
  final outgoingStreamController = StreamController<List<int>>();

  CronetGrpcTransportStream(Uri uri, this.engine) {
    final ffiCronet = engine.ffiCronet;
    final ffiCronetDart = engine.ffiCronetDart;
    final request = ffiCronet.Cronet_UrlRequest_Create();
    final requestParams = ffiCronet.Cronet_UrlRequestParams_Create();
    ffiCronet.Cronet_UrlRequestParams_http_method_set(requestParams,
        "POST".toNativeUtf8().cast<ffi.Int8>());
    final cronetCallbacks = ffiCronet.Cronet_UrlRequestCallback_CreateWith(
        ffiCronetDart.addresses.OnRedirectReceived.cast(),
        ffiCronetDart.addresses.OnResponseStarted.cast(),
        ffiCronetDart.addresses.OnReadCompleted.cast(),
        ffiCronetDart.addresses.OnSucceeded.cast(),
        ffiCronetDart.addresses.OnFailed.cast(),
        ffiCronetDart.addresses.OnCanceled.cast(),
    );
    final executor = ffiCronetDart.CronetTaskExecutorCreate();
    final callbackReceivePort = ReceivePort();
    ffiCronetDart.InitCronetTaskExecutor(executor);
    ffiCronetDart.RegisterCallbackHandler(callbackReceivePort.sendPort.nativePort,
        request.cast());

    outgoingStreamController.stream.toList().then((dataToUploadList) {
        // Blocked until data to upload gets available by GRPC client.
        final dataToUpload = grpc.frame(dataToUploadList[0]);
        print('dataToUpload: $dataToUpload');

        final callbackHandler = CallbackHandler(engine, executor, callbackReceivePort, dataToUpload);
        callbackHandler.incomingStreamController.stream
            .map((http2.StreamMessage streamMessage) {
              print('incoming stream got ${streamMessage}');
              return streamMessage; })
            .transform(grpc.GrpcHttpDecoder())
            .listen((grpc.GrpcMessage grpcmessage) {
              print('grpcmessage: $grpcmessage');
              incomingStreamController.add(grpcmessage);
            },
            onError: (error, stackTrace) {
              print('incoming stream failed $error, $stackTrace');
              incomingStreamController.addError(error, stackTrace);
            },
            onDone: () {
              print('incoming stream is done');
              incomingStreamController.close();
            });

        final cronetUploadProvider = ffiCronet.Cronet_UploadDataProvider_CreateWith(
            ffiCronetDart.addresses.UploadDataProvider_GetLength.cast(),
            ffiCronetDart.addresses.UploadDataProvider_Read.cast(),
            ffiCronetDart.addresses.UploadDataProvider_Rewind.cast(),
            ffiCronetDart.addresses.UploadDataProvider_Close.cast());
        final uploadProvider = ffiCronetDart.UploadDataProviderCreate();
        ffiCronet.Cronet_UploadDataProvider_SetClientContext(
            cronetUploadProvider, uploadProvider.cast());

        // outgoingStreamController.stream.listen((data) {
        //   print('outgoing data $data, ');
        //   // ffiCronet.Cronet_UploadDataProvider_Read(
        //   //     Cronet_UploadDataProviderPtr self,
        //   //     Cronet_UploadDataSinkPtr upload_data_sink,
        //   //     Cronet_BufferPtr buffer);
        // });

        ffiCronetDart.UploadDataProviderInit(
            uploadProvider, dataToUpload.length, request.cast());
        ffiCronet.Cronet_UrlRequestParams_upload_data_provider_set(
            requestParams, cronetUploadProvider);

        print('connecting to ${uri.toString()}');
        throwIfFailed(ffiCronet.Cronet_UrlRequest_InitWithParams(
            request,
            engine.ffiEngine,
            uri.toString().toNativeUtf8().cast<ffi.Int8>(),
            requestParams,
            cronetCallbacks,
            ffiCronetDart.CronetTaskExecutor_Cronet_ExecutorPtr_get(
                executor).cast()));
        ffiCronet.Cronet_UrlRequestParams_Destroy(requestParams);

        throwIfFailed(ffiCronet.Cronet_UrlRequest_Start(request));
        print('CronetGrpcTransportStream called Cronet_UrlRequest_Start $request');

        callbackHandler.listen(
            request); //, () { print('_clientCleanup(this)'); }, _dataToUpload.takeBytes());
    });
  }

  @override
  Stream<grpc.GrpcMessage> get incomingMessages {
    return incomingStreamController.stream;
  }

  @override
  StreamSink<List<int>> get outgoingMessages {
    return outgoingStreamController.sink;
  }

  @override
  Future<void> terminate() async {

  }

  final CronetEngine engine;
}

class CronetGrpcClientConnection implements grpc.ClientConnection {
  CronetGrpcClientConnection(this.host, this.port, this.options) {
    engine = new CronetEngine(options, "dart-cronet-grpc/0.0.1");
  }

  @override
  String get authority => host;
  @override
  String get scheme => options.credentials.isSecure ? 'https' : 'http';

  /// Put [call] on the queue to be dispatched when the connection is ready.
  @override
  void dispatchCall(grpc.ClientCall call) {
    call.onConnectionReady(this);
    print('CronetGrpcClientConnection dispatchCall $call');
  }

  /// Start a request for [path] with [metadata].
  @override
  grpc.GrpcTransportStream makeRequest(String path, Duration? timeout,
      Map<String, String> metadata, grpc.ErrorHandler onRequestFailure,
      {required grpc.CallOptions callOptions}) {
    print('CronetGrpcClientConnection makeRequest $path, metadata: $metadata');
    return engine.startBidirectionalStream(Uri(scheme: scheme, host: authority, path: path, port: port));
  }

  /// Shuts down this connection.
  ///
  /// No further calls may be made on this connection, but existing calls
  /// are allowed to finish.
  @override
  Future<void> shutdown() async {
  }

  /// Terminates this connection.
  ///
  /// All open calls are terminated immediately, and no further calls may be
  /// made on this connection.
  @override
  Future<void> terminate() async {
  }

  final String host;
  final int port;
  final grpc.ChannelOptions options;
  late final CronetEngine engine;
}

class CronetGrpcClientChannel extends grpc.ClientChannelBase {
  final String host;
  final int port;
  final grpc.ChannelOptions options;

  CronetGrpcClientChannel(this.host,
      {this.port = 443, this.options = const grpc.ChannelOptions()})
      : super();

  @override
  grpc.ClientConnection createConnection() {
    return CronetGrpcClientConnection(host, port, options);
  }
}
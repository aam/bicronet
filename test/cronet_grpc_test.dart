// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cronet_grpc/cronet_grpc.dart';
import 'package:grpc/grpc.dart';
import 'package:test/test.dart';

import 'generated/helloworld.pbgrpc.dart';

class GreeterService extends GreeterServiceBase {
  @override
  Future<HelloReply> sayHello(ServiceCall call, HelloRequest request) async {
    return HelloReply()..message = 'Hello, ${request.name}!';
  }
}

Future<void> connectAndSayHello(channel) async {
  final stub = GreeterClient(channel);

  try {
    final response = await stub.sayHello(
      HelloRequest()..name = 'world',
      options: CallOptions(compression: const GzipCodec()),
    );
    print('Greeter client received: ${response.message}');
  } catch (e) {
    print('Caught error: $e');
  }
  return await channel.shutdown();
}

Future<void> main() async {
  group('Basic', () {
    test('Initialize', () {
      final channel = CronetGrpcClientChannel('localhost', port: 443);
      final connection = channel.createConnection();
      final transportStream = connection.makeRequest('data',
          Duration(seconds: 10),
          /*metadata=*/ <String, String>{},
          (error, stackTrace) {
              print('Cronet request failure $error, $stackTrace');
          },
          callOptions: CallOptions());
    });
  }, skip: true);

  group('WithLocalServer', () {
    test('Connect', () async {
      final server = Server(
        [GreeterService()],
        const <Interceptor>[],
        CodecRegistry(codecs: const [GzipCodec(), IdentityCodec()]),
      );
      final serverContext = SecurityContextServerCredentials.baseSecurityContext();
      serverContext.useCertificateChain('test/data/private.crt');
      serverContext.usePrivateKey('test/data/private.key');
      serverContext.setTrustedCertificates('test/data/private.crt');
      final ServerCredentials serverCredentials =
          SecurityContextServerCredentials(serverContext);
      await server.serve(
          address: 'localhost',
          port: 60245,
          security: serverCredentials,
          requireClientCertificate: false);

      // await server.serve(port: 0);
      final serverPort = server.port;
      if (serverPort == null) {
        throw Exception("Failed to launch test server");
      }
      print('Listening on port ${server.port}...');
      // {
      //   final securityContext = SecurityContext();
      //   final client = HttpClient(context: securityContext);
      //   client.keyLog = (line) => print(line);
      //   try {
      //     HttpClientRequest request = await client.getUrl(Uri(scheme:'https', host:'localhost', port: serverPort, path: '/file.txt'));
      //     HttpClientResponse response = await request.close();
      //     final stringData = await response.transform(utf8.decoder).join();
      //     print(stringData);
      //   } finally {
      //     client.close();
      //   }

      // }

      final channelContext =
          SecurityContextChannelCredentials.baseSecurityContext();
      channelContext.useCertificateChain('test/data/private.crt');
      channelContext.usePrivateKey('test/data/private.key');
      final channelCredentials = SecurityContextChannelCredentials(channelContext,
          onBadCertificate: (cert, s) {
        print('onBadCertificate $cert $s');
        return true;
      });

      // {
      //   // Sanity check - using grpc client
      //   final channel = ClientChannel(
      //     'localhost',
      //     port: serverPort,
      //     options: ChannelOptions(
      //       credentials: channelCredentials, // ChannelCredentials.insecure(),
      //       codecRegistry:
      //           CodecRegistry(codecs: const [GzipCodec(), IdentityCodec()]),
      //     ),
      //   );
      //   await connectAndSayHello(channel);
      //   print('==============================');
      //   await channel.shutdown();
      // }

      final channel = CronetGrpcClientChannel(
          'localhost',
          port: serverPort,
          options: ChannelOptions(credentials: channelCredentials));
      await connectAndSayHello(channel);

      await channel.shutdown();
      await server.shutdown();
    }, timeout: Timeout.none);
  });
}

class SecurityContextChannelCredentials extends ChannelCredentials {
  final SecurityContext _securityContext;

  SecurityContextChannelCredentials(SecurityContext securityContext,
      {String? authority, BadCertificateHandler? onBadCertificate})
      : _securityContext = securityContext,
        super.secure(authority: authority, onBadCertificate: onBadCertificate);
  @override
  SecurityContext get securityContext => _securityContext;

  static SecurityContext baseSecurityContext() {
    return createSecurityContext(false);
  }
}

class SecurityContextServerCredentials extends ServerTlsCredentials {
  final SecurityContext _securityContext;

  SecurityContextServerCredentials(SecurityContext securityContext)
      : _securityContext = securityContext,
        super();
  @override
  SecurityContext get securityContext => _securityContext;
  static SecurityContext baseSecurityContext() {
    return createSecurityContext(true);
  }
}

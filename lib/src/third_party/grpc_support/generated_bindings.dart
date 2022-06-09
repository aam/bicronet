// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: camel_case_types
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: non_constant_identifier_names

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
import 'dart:ffi' as ffi;

/// Bindings to Cronet Grpc Support API
class GrpcSupport {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  GrpcSupport(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  GrpcSupport.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  /// Creates a new stream object that uses |engine| and |callback|. All stream
  /// tasks are performed asynchronously on the |engine| network thread. |callback|
  /// methods are invoked synchronously on the |engine| network thread, but must
  /// not run tasks on the current thread to prevent blocking networking operations
  /// and causing exceptions during shutdown. The |annotation| is stored in
  /// bidirectional stream for arbitrary use by application.
  ///
  /// Returned |bidirectional_stream*| is owned by the caller, and must be
  /// destroyed using |bidirectional_stream_destroy|.
  ///
  /// Both |calback| and |engine| must remain valid until stream is destroyed.
  ffi.Pointer<bidirectional_stream> bidirectional_stream_create(
    ffi.Pointer<stream_engine> engine,
    ffi.Pointer<ffi.Void> annotation,
    ffi.Pointer<bidirectional_stream_callback> callback,
  ) {
    return _bidirectional_stream_create(
      engine,
      annotation,
      callback,
    );
  }

  late final _bidirectional_stream_createPtr = _lookup<
          ffi.NativeFunction<
              ffi.Pointer<bidirectional_stream> Function(
                  ffi.Pointer<stream_engine>,
                  ffi.Pointer<ffi.Void>,
                  ffi.Pointer<bidirectional_stream_callback>)>>(
      'bidirectional_stream_create');
  late final _bidirectional_stream_create =
      _bidirectional_stream_createPtr.asFunction<
          ffi.Pointer<bidirectional_stream> Function(
              ffi.Pointer<stream_engine>,
              ffi.Pointer<ffi.Void>,
              ffi.Pointer<bidirectional_stream_callback>)>();

  /// Destroys stream object. Destroy could be called from any thread, including
  /// network thread, but is posted, so |stream| is valid until calling task is
  /// complete.
  int bidirectional_stream_destroy(
    ffi.Pointer<bidirectional_stream> stream,
  ) {
    return _bidirectional_stream_destroy(
      stream,
    );
  }

  late final _bidirectional_stream_destroyPtr = _lookup<
          ffi.NativeFunction<
              ffi.Int Function(ffi.Pointer<bidirectional_stream>)>>(
      'bidirectional_stream_destroy');
  late final _bidirectional_stream_destroy = _bidirectional_stream_destroyPtr
      .asFunction<int Function(ffi.Pointer<bidirectional_stream>)>();

  /// Disables or enables auto flush. By default, data is flushed after
  /// every bidirectional_stream_write(). If the auto flush is disabled,
  /// the client should explicitly call bidirectional_stream_flush to flush
  /// the data.
  void bidirectional_stream_disable_auto_flush(
    ffi.Pointer<bidirectional_stream> stream,
    bool disable_auto_flush,
  ) {
    return _bidirectional_stream_disable_auto_flush(
      stream,
      disable_auto_flush ? 1 : 0,
    );
  }

  late final _bidirectional_stream_disable_auto_flushPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<bidirectional_stream>,
              ffi.Uint8)>>('bidirectional_stream_disable_auto_flush');
  late final _bidirectional_stream_disable_auto_flush =
      _bidirectional_stream_disable_auto_flushPtr
          .asFunction<void Function(ffi.Pointer<bidirectional_stream>, int)>();

  /// Delays sending request headers until bidirectional_stream_flush()
  /// is called. This flag is currently only respected when QUIC is negotiated.
  /// When true, QUIC will send request header frame along with data frame(s)
  /// as a single packet when possible.
  void bidirectional_stream_delay_request_headers_until_flush(
    ffi.Pointer<bidirectional_stream> stream,
    bool delay_headers_until_flush,
  ) {
    return _bidirectional_stream_delay_request_headers_until_flush(
      stream,
      delay_headers_until_flush ? 1 : 0,
    );
  }

  late final _bidirectional_stream_delay_request_headers_until_flushPtr =
      _lookup<
              ffi.NativeFunction<
                  ffi.Void Function(
                      ffi.Pointer<bidirectional_stream>, ffi.Uint8)>>(
          'bidirectional_stream_delay_request_headers_until_flush');
  late final _bidirectional_stream_delay_request_headers_until_flush =
      _bidirectional_stream_delay_request_headers_until_flushPtr
          .asFunction<void Function(ffi.Pointer<bidirectional_stream>, int)>();

  /// Starts the stream by sending request to |url| using |method| and |headers|.
  /// If |end_of_stream| is true, then no data is expected to be written. The
  /// |method| is HTTP verb.
  int bidirectional_stream_start(
    ffi.Pointer<bidirectional_stream> stream,
    ffi.Pointer<ffi.Char> url,
    int priority,
    ffi.Pointer<ffi.Char> method,
    ffi.Pointer<bidirectional_stream_header_array> headers,
    bool end_of_stream,
  ) {
    return _bidirectional_stream_start(
      stream,
      url,
      priority,
      method,
      headers,
      end_of_stream ? 1 : 0,
    );
  }

  late final _bidirectional_stream_startPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              ffi.Pointer<bidirectional_stream>,
              ffi.Pointer<ffi.Char>,
              ffi.Int,
              ffi.Pointer<ffi.Char>,
              ffi.Pointer<bidirectional_stream_header_array>,
              ffi.Uint8)>>('bidirectional_stream_start');
  late final _bidirectional_stream_start =
      _bidirectional_stream_startPtr.asFunction<
          int Function(
              ffi.Pointer<bidirectional_stream>,
              ffi.Pointer<ffi.Char>,
              int,
              ffi.Pointer<ffi.Char>,
              ffi.Pointer<bidirectional_stream_header_array>,
              int)>();

  /// Reads response data into |buffer| of |capacity| length. Must only be called
  /// at most once in response to each invocation of the
  /// on_stream_ready()/on_response_headers_received() and on_read_completed()
  /// methods of the bidirectional_stream_callback.
  /// Each call will result in an invocation of the callback's
  /// on_read_completed() method if data is read, or its on_failed() method if
  /// there's an error. The callback's on_succeeded() method is also invoked if
  /// there is no more data to read and |end_of_stream| was previously sent.
  int bidirectional_stream_read(
    ffi.Pointer<bidirectional_stream> stream,
    ffi.Pointer<ffi.Char> buffer,
    int capacity,
  ) {
    return _bidirectional_stream_read(
      stream,
      buffer,
      capacity,
    );
  }

  late final _bidirectional_stream_readPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<bidirectional_stream>,
              ffi.Pointer<ffi.Char>, ffi.Int)>>('bidirectional_stream_read');
  late final _bidirectional_stream_read =
      _bidirectional_stream_readPtr.asFunction<
          int Function(
              ffi.Pointer<bidirectional_stream>, ffi.Pointer<ffi.Char>, int)>();

  /// Writes request data from |buffer| of |buffer_length| length. If auto flush is
  /// disabled, data will be sent only after bidirectional_stream_flush() is
  /// called.
  /// Each call will result in an invocation the callback's on_write_completed()
  /// method if data is sent, or its on_failed() method if there's an error.
  /// The callback's on_succeeded() method is also invoked if |end_of_stream| is
  /// set and all response data has been read.
  int bidirectional_stream_write(
    ffi.Pointer<bidirectional_stream> stream,
    ffi.Pointer<ffi.Char> buffer,
    int buffer_length,
    bool end_of_stream,
  ) {
    return _bidirectional_stream_write(
      stream,
      buffer,
      buffer_length,
      end_of_stream ? 1 : 0,
    );
  }

  late final _bidirectional_stream_writePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              ffi.Pointer<bidirectional_stream>,
              ffi.Pointer<ffi.Char>,
              ffi.Int,
              ffi.Uint8)>>('bidirectional_stream_write');
  late final _bidirectional_stream_write =
      _bidirectional_stream_writePtr.asFunction<
          int Function(ffi.Pointer<bidirectional_stream>, ffi.Pointer<ffi.Char>,
              int, int)>();

  /// Flushes pending writes. This method should not be called before invocation of
  /// on_stream_ready() method of the bidirectional_stream_callback.
  /// For each previously called bidirectional_stream_write()
  /// a corresponding on_write_completed() callback will be invoked when the buffer
  /// is sent.
  void bidirectional_stream_flush(
    ffi.Pointer<bidirectional_stream> stream,
  ) {
    return _bidirectional_stream_flush(
      stream,
    );
  }

  late final _bidirectional_stream_flushPtr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Pointer<bidirectional_stream>)>>(
      'bidirectional_stream_flush');
  late final _bidirectional_stream_flush = _bidirectional_stream_flushPtr
      .asFunction<void Function(ffi.Pointer<bidirectional_stream>)>();

  /// Cancels the stream. Can be called at any time after
  /// bidirectional_stream_start(). The on_canceled() method of
  /// bidirectional_stream_callback will be invoked when cancelation
  /// is complete and no further callback methods will be invoked. If the
  /// stream has completed or has not started, calling
  /// bidirectional_stream_cancel() has no effect and on_canceled() will not
  /// be invoked. At most one callback method may be invoked after
  /// bidirectional_stream_cancel() has completed.
  void bidirectional_stream_cancel(
    ffi.Pointer<bidirectional_stream> stream,
  ) {
    return _bidirectional_stream_cancel(
      stream,
    );
  }

  late final _bidirectional_stream_cancelPtr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Pointer<bidirectional_stream>)>>(
      'bidirectional_stream_cancel');
  late final _bidirectional_stream_cancel = _bidirectional_stream_cancelPtr
      .asFunction<void Function(ffi.Pointer<bidirectional_stream>)>();

  /// Returns true if the |stream| was successfully started and is now done
  /// (succeeded, canceled, or failed).
  /// Returns false if the |stream| stream is not yet started or is in progress.
  bool bidirectional_stream_is_done(
    ffi.Pointer<bidirectional_stream> stream,
  ) {
    return _bidirectional_stream_is_done(
          stream,
        ) !=
        0;
  }

  late final _bidirectional_stream_is_donePtr = _lookup<
          ffi.NativeFunction<
              ffi.Uint8 Function(ffi.Pointer<bidirectional_stream>)>>(
      'bidirectional_stream_is_done');
  late final _bidirectional_stream_is_done = _bidirectional_stream_is_donePtr
      .asFunction<int Function(ffi.Pointer<bidirectional_stream>)>();

  /// Creates a new stream object that uses |engine| and |callback|. All stream
  /// tasks are performed asynchronously on the |engine| network thread. |callback|
  /// methods are invoked synchronously on the |engine| network thread, but must
  /// not run tasks on the current thread to prevent blocking networking operations
  /// and causing exceptions during shutdown. The |annotation| is stored in
  /// bidirectional stream for arbitrary use by application.
  ///
  /// Returned |bidirectional_stream*| is owned by the caller, and must be
  /// destroyed using |bidirectional_stream_destroy|.
  ///
  /// Both |calback| and |engine| must remain valid until stream is destroyed.
  ffi.Pointer<bidirectional_stream> bidirectional_stream_create1(
    ffi.Pointer<stream_engine> engine,
    ffi.Pointer<ffi.Void> annotation,
    ffi.Pointer<bidirectional_stream_callback> callback,
  ) {
    return _bidirectional_stream_create1(
      engine,
      annotation,
      callback,
    );
  }

  late final _bidirectional_stream_create1Ptr = _lookup<
          ffi.NativeFunction<
              ffi.Pointer<bidirectional_stream> Function(
                  ffi.Pointer<stream_engine>,
                  ffi.Pointer<ffi.Void>,
                  ffi.Pointer<bidirectional_stream_callback>)>>(
      'bidirectional_stream_create');
  late final _bidirectional_stream_create1 =
      _bidirectional_stream_create1Ptr.asFunction<
          ffi.Pointer<bidirectional_stream> Function(
              ffi.Pointer<stream_engine>,
              ffi.Pointer<ffi.Void>,
              ffi.Pointer<bidirectional_stream_callback>)>();

  /// Destroys stream object. Destroy could be called from any thread, including
  /// network thread, but is posted, so |stream| is valid until calling task is
  /// complete.
  int bidirectional_stream_destroy1(
    ffi.Pointer<bidirectional_stream> stream,
  ) {
    return _bidirectional_stream_destroy1(
      stream,
    );
  }

  late final _bidirectional_stream_destroy1Ptr = _lookup<
          ffi.NativeFunction<
              ffi.Int Function(ffi.Pointer<bidirectional_stream>)>>(
      'bidirectional_stream_destroy');
  late final _bidirectional_stream_destroy1 = _bidirectional_stream_destroy1Ptr
      .asFunction<int Function(ffi.Pointer<bidirectional_stream>)>();

  /// Disables or enables auto flush. By default, data is flushed after
  /// every bidirectional_stream_write(). If the auto flush is disabled,
  /// the client should explicitly call bidirectional_stream_flush to flush
  /// the data.
  void bidirectional_stream_disable_auto_flush1(
    ffi.Pointer<bidirectional_stream> stream,
    bool disable_auto_flush,
  ) {
    return _bidirectional_stream_disable_auto_flush1(
      stream,
      disable_auto_flush ? 1 : 0,
    );
  }

  late final _bidirectional_stream_disable_auto_flush1Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<bidirectional_stream>,
              ffi.Uint8)>>('bidirectional_stream_disable_auto_flush');
  late final _bidirectional_stream_disable_auto_flush1 =
      _bidirectional_stream_disable_auto_flush1Ptr
          .asFunction<void Function(ffi.Pointer<bidirectional_stream>, int)>();

  /// Delays sending request headers until bidirectional_stream_flush()
  /// is called. This flag is currently only respected when QUIC is negotiated.
  /// When true, QUIC will send request header frame along with data frame(s)
  /// as a single packet when possible.
  void bidirectional_stream_delay_request_headers_until_flush1(
    ffi.Pointer<bidirectional_stream> stream,
    bool delay_headers_until_flush,
  ) {
    return _bidirectional_stream_delay_request_headers_until_flush1(
      stream,
      delay_headers_until_flush ? 1 : 0,
    );
  }

  late final _bidirectional_stream_delay_request_headers_until_flush1Ptr =
      _lookup<
              ffi.NativeFunction<
                  ffi.Void Function(
                      ffi.Pointer<bidirectional_stream>, ffi.Uint8)>>(
          'bidirectional_stream_delay_request_headers_until_flush');
  late final _bidirectional_stream_delay_request_headers_until_flush1 =
      _bidirectional_stream_delay_request_headers_until_flush1Ptr
          .asFunction<void Function(ffi.Pointer<bidirectional_stream>, int)>();

  /// Starts the stream by sending request to |url| using |method| and |headers|.
  /// If |end_of_stream| is true, then no data is expected to be written. The
  /// |method| is HTTP verb.
  int bidirectional_stream_start1(
    ffi.Pointer<bidirectional_stream> stream,
    ffi.Pointer<ffi.Char> url,
    int priority,
    ffi.Pointer<ffi.Char> method,
    ffi.Pointer<bidirectional_stream_header_array> headers,
    bool end_of_stream,
  ) {
    return _bidirectional_stream_start1(
      stream,
      url,
      priority,
      method,
      headers,
      end_of_stream ? 1 : 0,
    );
  }

  late final _bidirectional_stream_start1Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              ffi.Pointer<bidirectional_stream>,
              ffi.Pointer<ffi.Char>,
              ffi.Int,
              ffi.Pointer<ffi.Char>,
              ffi.Pointer<bidirectional_stream_header_array>,
              ffi.Uint8)>>('bidirectional_stream_start');
  late final _bidirectional_stream_start1 =
      _bidirectional_stream_start1Ptr.asFunction<
          int Function(
              ffi.Pointer<bidirectional_stream>,
              ffi.Pointer<ffi.Char>,
              int,
              ffi.Pointer<ffi.Char>,
              ffi.Pointer<bidirectional_stream_header_array>,
              int)>();

  /// Reads response data into |buffer| of |capacity| length. Must only be called
  /// at most once in response to each invocation of the
  /// on_stream_ready()/on_response_headers_received() and on_read_completed()
  /// methods of the bidirectional_stream_callback.
  /// Each call will result in an invocation of the callback's
  /// on_read_completed() method if data is read, or its on_failed() method if
  /// there's an error. The callback's on_succeeded() method is also invoked if
  /// there is no more data to read and |end_of_stream| was previously sent.
  int bidirectional_stream_read1(
    ffi.Pointer<bidirectional_stream> stream,
    ffi.Pointer<ffi.Char> buffer,
    int capacity,
  ) {
    return _bidirectional_stream_read1(
      stream,
      buffer,
      capacity,
    );
  }

  late final _bidirectional_stream_read1Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(ffi.Pointer<bidirectional_stream>,
              ffi.Pointer<ffi.Char>, ffi.Int)>>('bidirectional_stream_read');
  late final _bidirectional_stream_read1 =
      _bidirectional_stream_read1Ptr.asFunction<
          int Function(
              ffi.Pointer<bidirectional_stream>, ffi.Pointer<ffi.Char>, int)>();

  /// Writes request data from |buffer| of |buffer_length| length. If auto flush is
  /// disabled, data will be sent only after bidirectional_stream_flush() is
  /// called.
  /// Each call will result in an invocation the callback's on_write_completed()
  /// method if data is sent, or its on_failed() method if there's an error.
  /// The callback's on_succeeded() method is also invoked if |end_of_stream| is
  /// set and all response data has been read.
  int bidirectional_stream_write1(
    ffi.Pointer<bidirectional_stream> stream,
    ffi.Pointer<ffi.Char> buffer,
    int buffer_length,
    bool end_of_stream,
  ) {
    return _bidirectional_stream_write1(
      stream,
      buffer,
      buffer_length,
      end_of_stream ? 1 : 0,
    );
  }

  late final _bidirectional_stream_write1Ptr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              ffi.Pointer<bidirectional_stream>,
              ffi.Pointer<ffi.Char>,
              ffi.Int,
              ffi.Uint8)>>('bidirectional_stream_write');
  late final _bidirectional_stream_write1 =
      _bidirectional_stream_write1Ptr.asFunction<
          int Function(ffi.Pointer<bidirectional_stream>, ffi.Pointer<ffi.Char>,
              int, int)>();

  /// Flushes pending writes. This method should not be called before invocation of
  /// on_stream_ready() method of the bidirectional_stream_callback.
  /// For each previously called bidirectional_stream_write()
  /// a corresponding on_write_completed() callback will be invoked when the buffer
  /// is sent.
  void bidirectional_stream_flush1(
    ffi.Pointer<bidirectional_stream> stream,
  ) {
    return _bidirectional_stream_flush1(
      stream,
    );
  }

  late final _bidirectional_stream_flush1Ptr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Pointer<bidirectional_stream>)>>(
      'bidirectional_stream_flush');
  late final _bidirectional_stream_flush1 = _bidirectional_stream_flush1Ptr
      .asFunction<void Function(ffi.Pointer<bidirectional_stream>)>();

  /// Cancels the stream. Can be called at any time after
  /// bidirectional_stream_start(). The on_canceled() method of
  /// bidirectional_stream_callback will be invoked when cancelation
  /// is complete and no further callback methods will be invoked. If the
  /// stream has completed or has not started, calling
  /// bidirectional_stream_cancel() has no effect and on_canceled() will not
  /// be invoked. At most one callback method may be invoked after
  /// bidirectional_stream_cancel() has completed.
  void bidirectional_stream_cancel1(
    ffi.Pointer<bidirectional_stream> stream,
  ) {
    return _bidirectional_stream_cancel1(
      stream,
    );
  }

  late final _bidirectional_stream_cancel1Ptr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Pointer<bidirectional_stream>)>>(
      'bidirectional_stream_cancel');
  late final _bidirectional_stream_cancel1 = _bidirectional_stream_cancel1Ptr
      .asFunction<void Function(ffi.Pointer<bidirectional_stream>)>();

  /// Returns true if the |stream| was successfully started and is now done
  /// (succeeded, canceled, or failed).
  /// Returns false if the |stream| stream is not yet started or is in progress.
  bool bidirectional_stream_is_done1(
    ffi.Pointer<bidirectional_stream> stream,
  ) {
    return _bidirectional_stream_is_done1(
          stream,
        ) !=
        0;
  }

  late final _bidirectional_stream_is_done1Ptr = _lookup<
          ffi.NativeFunction<
              ffi.Uint8 Function(ffi.Pointer<bidirectional_stream>)>>(
      'bidirectional_stream_is_done');
  late final _bidirectional_stream_is_done1 = _bidirectional_stream_is_done1Ptr
      .asFunction<int Function(ffi.Pointer<bidirectional_stream>)>();

  ffi.Pointer<stream_engine> bidirectional_stream_engine_create(
    bool enable_quic,
    ffi.Pointer<ffi.Char> quic_user_agent_id,
    bool enable_spdy,
    bool enable_brotli,
    ffi.Pointer<ffi.Char> accept_language,
    ffi.Pointer<ffi.Char> user_agent,
  ) {
    return _bidirectional_stream_engine_create(
      enable_quic ? 1 : 0,
      quic_user_agent_id,
      enable_spdy ? 1 : 0,
      enable_brotli ? 1 : 0,
      accept_language,
      user_agent,
    );
  }

  late final _bidirectional_stream_engine_createPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<stream_engine> Function(
              ffi.Uint8,
              ffi.Pointer<ffi.Char>,
              ffi.Uint8,
              ffi.Uint8,
              ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Char>)>>('bidirectional_stream_engine_create');
  late final _bidirectional_stream_engine_create =
      _bidirectional_stream_engine_createPtr.asFunction<
          ffi.Pointer<stream_engine> Function(int, ffi.Pointer<ffi.Char>, int,
              int, ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>)>();

  void bidirectional_stream_engine_destroy(
    ffi.Pointer<stream_engine> s_engine,
  ) {
    return _bidirectional_stream_engine_destroy(
      s_engine,
    );
  }

  late final _bidirectional_stream_engine_destroyPtr = _lookup<
          ffi.NativeFunction<ffi.Void Function(ffi.Pointer<stream_engine>)>>(
      'bidirectional_stream_engine_destroy');
  late final _bidirectional_stream_engine_destroy =
      _bidirectional_stream_engine_destroyPtr
          .asFunction<void Function(ffi.Pointer<stream_engine>)>();
}

class max_align_t extends ffi.Opaque {}

/// Opaque object representing a Bidirectional stream creating engine. Created
/// and configured outside of this API to facilitate sharing with other
/// components
class stream_engine extends ffi.Struct {
  external ffi.Pointer<ffi.Void> obj;

  external ffi.Pointer<ffi.Void> annotation;
}

/// Opaque object representing Bidirectional Stream.
class bidirectional_stream extends ffi.Struct {
  external ffi.Pointer<ffi.Void> obj;

  external ffi.Pointer<ffi.Void> annotation;
}

/// A single request or response header element.
class bidirectional_stream_header extends ffi.Struct {
  external ffi.Pointer<ffi.Char> key;

  external ffi.Pointer<ffi.Char> value;
}

/// Array of request or response headers or trailers.
class bidirectional_stream_header_array extends ffi.Struct {
  @ffi.Size()
  external int count;

  @ffi.Size()
  external int capacity;

  external ffi.Pointer<bidirectional_stream_header> headers;
}

/// Set of callbacks used to receive callbacks from bidirectional stream.
class bidirectional_stream_callback extends ffi.Struct {
  /// Invoked when the stream is ready for reading and writing.
  /// Consumer may call bidirectional_stream_read() to start reading data.
  /// Consumer may call bidirectional_stream_write() to start writing
  /// data.
  external ffi.Pointer<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Pointer<bidirectional_stream>)>>
      on_stream_ready;

  /// Invoked when initial response headers are received.
  /// Consumer must call bidirectional_stream_read() to start reading.
  /// Consumer may call bidirectional_stream_write() to start writing or
  /// close the stream. Contents of |headers| is valid for duration of the call.
  external ffi.Pointer<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Pointer<bidirectional_stream>,
              ffi.Pointer<bidirectional_stream_header_array>,
              ffi.Pointer<ffi.Char>)>> on_response_headers_received;

  /// Invoked when data is read into the buffer passed to
  /// bidirectional_stream_read(). Only part of the buffer may be
  /// populated. To continue reading, call bidirectional_stream_read().
  /// It may be invoked after on_response_trailers_received()}, if there was
  /// pending read data before trailers were received.
  ///
  /// If |bytes_read| is 0, it means the remote side has signaled that it will
  /// send no more data; future calls to bidirectional_stream_read()
  /// will result in the on_data_read() callback or on_succeded() callback if
  /// bidirectional_stream_write() was invoked with end_of_stream set to
  /// true.
  external ffi.Pointer<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<bidirectional_stream>,
              ffi.Pointer<ffi.Char>, ffi.Int)>> on_read_completed;

  /// Invoked when all data passed to bidirectional_stream_write() is
  /// sent. To continue writing, call bidirectional_stream_write().
  external ffi.Pointer<
          ffi.NativeFunction<
              ffi.Void Function(
                  ffi.Pointer<bidirectional_stream>, ffi.Pointer<ffi.Char>)>>
      on_write_completed;

  /// Invoked when trailers are received before closing the stream. Only invoked
  /// when server sends trailers, which it may not. May be invoked while there is
  /// read data remaining in local buffer. Contents of |trailers| is valid for
  /// duration of the call.
  external ffi.Pointer<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Pointer<bidirectional_stream>,
                  ffi.Pointer<bidirectional_stream_header_array>)>>
      on_response_trailers_received;

  /// Invoked when there is no data to be read or written and the stream is
  /// closed successfully remotely and locally. Once invoked, no further callback
  /// methods will be invoked.
  external ffi.Pointer<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<bidirectional_stream>)>> on_succeded;

  /// Invoked if the stream failed for any reason after
  /// bidirectional_stream_start(). HTTP/2 error codes are
  /// mapped to chrome net error codes. Once invoked, no further callback methods
  /// will be invoked.
  external ffi.Pointer<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Pointer<bidirectional_stream>, ffi.Int)>>
      on_failed;

  /// Invoked if the stream was canceled via
  /// bidirectional_stream_cancel(). Once invoked, no further callback
  /// methods will be invoked.
  external ffi.Pointer<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<bidirectional_stream>)>> on_canceled;
}

const int NULL = 0;

const int true1 = 1;

const int false1 = 0;

const int __bool_true_false_are_defined = 1;
// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: camel_case_types
// ignore_for_file: constant_identifier_names
// ignore_for_file: non_constant_identifier_names

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
import 'dart:ffi' as ffi;

/// Bindings to Cronet Dart API
class CronetDart {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  CronetDart(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  CronetDart.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  /// Initialization
  int InitDartApiDL(
    ffi.Pointer<ffi.Void> data,
  ) {
    return _InitDartApiDL(
      data,
    );
  }

  late final _InitDartApiDLPtr =
      _lookup<ffi.NativeFunction<ffi.IntPtr Function(ffi.Pointer<ffi.Void>)>>(
          'InitDartApiDL');
  late final _InitDartApiDL =
      _InitDartApiDLPtr.asFunction<int Function(ffi.Pointer<ffi.Void>)>();

  /// Creates new bidirectional stream with [send_port] that will be used
  /// by the engine to communicate a need for a callback to be invoked.
  ffi.Pointer<bidirectional_stream> CreateStreamWithCallbackPort(
    ffi.Pointer<stream_engine> engine,
    int send_port,
  ) {
    return _CreateStreamWithCallbackPort(
      engine,
      send_port,
    );
  }

  late final _CreateStreamWithCallbackPortPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<bidirectional_stream> Function(ffi.Pointer<stream_engine>,
              Dart_Port)>>('CreateStreamWithCallbackPort');
  late final _CreateStreamWithCallbackPort =
      _CreateStreamWithCallbackPortPtr.asFunction<
          ffi.Pointer<bidirectional_stream> Function(
              ffi.Pointer<stream_engine>, int)>();
}

class CronetTaskExecutor extends ffi.Opaque {}

class UploadDataProvider extends ffi.Opaque {}

/// Opaque object representing Bidirectional Stream.
class bidirectional_stream extends ffi.Struct {
  external ffi.Pointer<ffi.Void> obj;

  external ffi.Pointer<ffi.Void> annotation;
}

/// Opaque object representing a Bidirectional stream creating engine. Created
/// and configured outside of this API to facilitate sharing with other
/// components
class stream_engine extends ffi.Struct {
  external ffi.Pointer<ffi.Void> obj;

  external ffi.Pointer<ffi.Void> annotation;
}

/// A port is used to send or receive inter-isolate messages
typedef Dart_Port = ffi.Int64;

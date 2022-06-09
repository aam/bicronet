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
  final serverPort = server.port;
  if (serverPort == null) {
    throw Exception("Failed to launch test server");
  }
  print('Listening on port ${server.port}...');
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

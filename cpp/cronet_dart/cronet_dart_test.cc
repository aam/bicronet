#include <string>
#include <memory>
#include <stdio.h>

// #include "base/strings/stringprintf.h"

//#include "components/grpc_support/bidirectional_stream.h"

//#include "net/cert/mock_cert_verifier.h"
// #include "net/cert/multi_threaded_cert_verifier.h"
// #include "net/cert/cert_verify_proc.h"
// #include "net/cert/cert_verify_result.h"
// #include "net/cert/x509_certificate.h"

// #include "components/cronet/native/include/cronet_c.h"
// #include "components/cronet/native/engine.h"
// #include "components/cronet/native/generated/cronet.idl_c.h"
// #include "components/cronet/native/bidirectional_stream_engine.h"
// #include "components/grpc_support/include/bidirectional_stream_c.h"

#include "../third_party/grpc_support/bidirectional_stream_c.h"
#include "../third_party/cronet/native/bidirectional_stream_engine.h"

const int read_buffer_size = 1024;
char read_buffer[read_buffer_size];

// static void DispatchCallback(const char *methodname, Dart_Port dart_port,
//                       Dart_CObject args) {
//   Dart_CObject c_method_name;
//   c_method_name.type = Dart_CObject_kString;
//   c_method_name.value.as_string = const_cast<char *>(methodname);

//   Dart_CObject *c_request_arr[] = {&c_method_name, &args};
//   Dart_CObject c_request;

//   c_request.type = Dart_CObject_kArray;
//   c_request.value.as_array.values = c_request_arr;
//   c_request.value.as_array.length =
//       sizeof(c_request_arr) / sizeof(c_request_arr[0]);

//   Dart_PostCObject_DL(dart_port, &c_request);
// }

// static void FreeFinalizer(void *, void *value) { free(value); }

// // Builds the arguments to pass to the Dart side as a parameter to the
// // callbacks. [num] is the number of arguments to be passed and rest are the
// // arguments.
// static Dart_CObject CallbackArgBuilder(int num, ...) {
//   Dart_CObject c_request_data;
//   va_list valist;
//   va_start(valist, num);
//   void *request_buffer = malloc(sizeof(uint64_t) * num);
//   uint64_t *buf = reinterpret_cast<uint64_t *>(request_buffer);

//   // uintptr_r will get implicitly casted to uint64_t. So, when the code is
//   // executed in 32 bit mode, the upper 32 bit of buf[i] will be 0 extended
//   // automatically. This is required because, on the Dart side these addresses
//   // are viewed as 64 bit integers.
//   for (int i = 0; i < num; i++) {
//     buf[i] = va_arg(valist, uintptr_t);
//   }

//   c_request_data.type = Dart_CObject_kExternalTypedData;
//   c_request_data.value.as_external_typed_data.type = Dart_TypedData_kUint8;
//   c_request_data.value.as_external_typed_data.length = sizeof(uint64_t) * num;
//   c_request_data.value.as_external_typed_data.data =
//       static_cast<uint8_t *>(request_buffer);
//   c_request_data.value.as_external_typed_data.peer = request_buffer;
//   c_request_data.value.as_external_typed_data.callback = FreeFinalizer;

//   va_end(valist);

//   return c_request_data;
// }

static void on_stream_ready(bidirectional_stream* stream) {
  fprintf(stderr, "on_stream_ready %p\n", stream);
  // DispatchCallback("on_stream_ready",
  //                  std::reinterpret_cast<Dart_Port>(stream->annotation),
  //                  CallbackArgBuilder(0));
}

static void on_response_headers_received(
    bidirectional_stream* stream,
    const bidirectional_stream_header_array* headers,
    const char* negotiated_protocol) {
  fprintf(stderr, "on_response_headers_received %p\n", stream);

  for (int i = 0; i < headers->count; ++i) {
    fprintf(stderr, "header[%d]: %s %s\n", i, headers->headers[i].key,
            headers->headers[i].value);
  }

  bidirectional_stream_read(stream, read_buffer, read_buffer_size);
  fprintf(stderr, "stream_read: %p\n", read_buffer);
}

static void on_read_completed(bidirectional_stream* stream,
                          char* data,
                          int bytes_read) {
  fprintf(stderr, "on_read_completed %p bytes_read:%d data:%s\n", stream,
          bytes_read, data);
}

static void on_write_completed(bidirectional_stream* stream, const char* data) {
  fprintf(stderr, "on_write_completed %p\n", stream);
}

static void on_response_trailers_received(
    bidirectional_stream* stream,
    const bidirectional_stream_header_array* trailers) {
  fprintf(stderr, "on_response_trailers_received %p\n", stream);
  for (int i = 0; i < trailers->count; ++i) {
    fprintf(stderr, "trailer[%d]: %s %s\n", i, trailers->headers[i].key,
            trailers->headers[i].value);
  }
}

static void on_succeded(bidirectional_stream* stream) {
  fprintf(stderr, "on_succeded %p\n", stream);
}

static void on_failed(bidirectional_stream* stream, int net_error) {
  fprintf(stderr, "on_failed %p net_error:%d\n", stream, net_error);
}

static void on_canceled(bidirectional_stream* stream) {
  fprintf(stderr, "on_canceled %p\n", stream);
}

//  class TestCertVerifier : public net::MockCertVerifier {
//   public:
//    TestCertVerifier() = default;
//    ~TestCertVerifier() override = default;

//    // CertVerifier implementation
//    int Verify(const RequestParams& params,
//               net::CertVerifyResult* verify_result,
//               net::CompletionOnceCallback callback,
//               std::unique_ptr<Request>* out_req,
//               const net::NetLogWithSource& net_log) override {
//      //     verify_result->Reset();
// //     if (params.hostname() == "test.example.com") {
// //       verify_result->verified_cert = params.certificate();
// //       verify_result->is_issued_by_known_root = true;
//        return net::OK;
// //     }
// //     return net::MockCertVerifier::Verify(params, verify_result,
// //                                          std::move(callback), out_req, net_log);
//    }
// };

/*
class MockCertVerifyProc : public net::CertVerifyProc {
 public:
  virtual
  int VerifyInternal(net::X509Certificate* cert,
                     const std::string& hostname,
                     const std::string& ocsp_response,
                     const std::string& sct_list,
                     int flags,
                     net::CRLSet* crl_set,
                     const net::CertificateList& additional_trust_anchors,
                     net::CertVerifyResult* verify_result,
                     const net::NetLogWithSource& net_log) {
    verify_result->verified_cert = cert;
    verify_result->cert_status = 0;
    return net::OK;
  }
  virtual bool SupportsAdditionalTrustAnchors() const { return true; }

 private:
  ~MockCertVerifyProc() override = default;
};

Cronet_EnginePtr CreateTestEngine(int quic_server_port) {
  Cronet_EngineParamsPtr engine_params = Cronet_EngineParams_Create();
  Cronet_EngineParams_user_agent_set(engine_params, "test");
  // Add Host Resolver Rules.
  // std::string host_resolver_rules = base::StringPrintf(
  //     "MAP test.example.com 127.0.0.1:%d,"
  //     "MAP notfound.example.com ~NOTFOUND",
  //     quic_server_port);
  // Cronet_EngineParams_experimental_options_set(
  //     engine_params,
  //     base::StringPrintf(
  //         "{ \"HostResolverRules\": { \"host_resolver_rules\" : \"%s\" } }",
  //         host_resolver_rules.c_str())
  //         .c_str());
  // Enable QUIC.
  Cronet_EngineParams_enable_quic_set(engine_params, true);
  // Add QUIC Hint.
  Cronet_QuicHintPtr quic_hint = Cronet_QuicHint_Create();
  Cronet_QuicHint_host_set(quic_hint, "test.example.com");
  Cronet_QuicHint_port_set(quic_hint, 443);
  Cronet_QuicHint_alternate_port_set(quic_hint, 443);
  Cronet_EngineParams_quic_hints_add(engine_params, quic_hint);
  Cronet_QuicHint_Destroy(quic_hint);
  // Create Cronet Engine.
  Cronet_EnginePtr cronet_engine = Cronet_Engine_Create();
  // Set Mock Cert Verifier.
  // auto cert_verifier = std::make_unique<TestCertVerifier>();
  // Cronet_Engine_SetMockCertVerifierForTesting(cronet_engine,
  //                                             cert_verifier.release());
  // auto cert_verifier = std::make_unique<net::MockCertVerifier>();
  // cert_verifier->set_default_result(net::OK);
  // auto cert_verifier = std::make_unique<net::MultiThreadedCertVerifier>(
  //     base::MakeRefCounted<MockCertVerifyProc>());

  //auto cert_verifier = net::CertVerifier::kaka(nullptr);
  // auto cert_verify_proc = net::CertVerifyProc::CreateBuiltinVerifyProc(nullptr);
  // auto cert_verifier = new net::MultiThreadedCertVerifier(cert_verify_proc);
  // Cronet_Engine_SetMockCertVerifierForTesting(cronet_engine,
  //                                             cert_verifier);//.release());
  // Start Cronet Engine.
  Cronet_Engine_StartWithParams(cronet_engine, engine_params);
  Cronet_EngineParams_Destroy(engine_params);
  return cronet_engine;

}
*/
bidirectional_stream* stream;

bidirectional_stream_header kTestHeaders[] = {
    {"header1", "foo"},
    {"header2", "bar"},
};

const bidirectional_stream_header_array kTestHeadersArray = {2, 2,
                                                             kTestHeaders};

//base::WaitableEvent stream_done_event;

int main(int argc, char** argv) {
  fprintf(stderr, "Hello, world!\n");

  // BidirectionalStreamAdapter* stream_adapter =
  //     new BidirectionalStreamAdapter(engine, annotation, callback);
  // fprintf(stderr, "bidirectional_stream: %p\n", stream_adapter->c_stream());

//  Cronet_EnginePtr g_cronet_engine = Cronet_Engine_NewEngine(1234);
  //Cronet_EnginePtr g_cronet_engine = CreateTestEngine(1234);
  //stream_engine* engine = Cronet_Engine_GetStreamEngine(g_cronet_engine);

  stream_engine* engine = bidirectional_stream_engine_create(
      /*enable_quic=*/true,
      /*quic_user_agent_id=*/"my_quic_user_agent_id",
      /*enable_spdy=*/true,
      /*enable_brotli=*/true,
      /*accept_language=*/"en-us",
      "my_user_agent");


  void* annotation = nullptr;
  struct bidirectional_stream_callback callbacks = {
    on_stream_ready,
    on_response_headers_received,
    on_read_completed,
    on_write_completed,
    on_response_trailers_received,
    on_succeded,
    on_failed,
    on_canceled
  };

  stream = bidirectional_stream_create(engine, nullptr, &callbacks);

  bidirectional_stream_start(stream, "https://localhost:60245/abc", //test.example.com/hello.txt",
                             /*priority=*/0, "POST", &kTestHeadersArray,
                             /*end_of_stream=*/true);
  // block for done
  //stream_done_event.Wait();
  while(true) {}
}

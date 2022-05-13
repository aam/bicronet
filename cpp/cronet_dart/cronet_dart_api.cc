// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "cronet_dart_api.h"

#include <condition_variable>
#include <iostream>
#include <mutex>
#include <queue>
#include <thread>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <unordered_map>

//
// Big zoo of global entry points, initialized via |InitCronetDartApi|.
//

EngineShutdownCallback _Cronet_Engine_Shutdown;
EngineDestroyCallback _Cronet_Engine_Destroy;
BufferCreateCallback _Cronet_Buffer_Create;
BufferInitWithAllocCallback  _Cronet_Buffer_InitWithAlloc;
UrlResponseInfoHttpStatusCodeGetCallback
    _Cronet_UrlResponseInfo_http_status_code_get;
ErrorMessageGetCallback _Cronet_Error_message_get;
UrlResponseInfoHttpStatusTextGetCallback
    _Cronet_UrlResponseInfo_http_status_text_get;
UploadDataProviderGetClientContextCallback
        _Cronet_UploadDataProvider_GetClientContext;
ExecutorCreateWithCallback _Cronet_Executor_CreateWith;
ExecutorSetClientContextCallback _Cronet_Executor_SetClientContext;
ExecutorGetClientContextCallback _Cronet_Executor_GetClientContext;
ExecutorDestroyCallback _Cronet_Executor_Destroy;
RunnableRunCallback _Cronet_Runnable_Run;
RunnableDestroyCallback _Cronet_Runnable_Destroy;

intptr_t InitDartApiDL(void *data) {
  return Dart_InitializeApiDL(data);
}

void InitCronetDartApi(
    EngineShutdownCallback engine_shutdown,
    EngineDestroyCallback engine_destroy,
    BufferCreateCallback buffer_create,
    BufferInitWithAllocCallback  buffer_init_with_alloc,
    UrlResponseInfoHttpStatusCodeGetCallback http_status_code_get,
    ErrorMessageGetCallback error_message_get,
    UrlResponseInfoHttpStatusTextGetCallback http_status_text_get,
    UploadDataProviderGetClientContextCallback
        upload_provider_get_client_context,
    ExecutorCreateWithCallback create_with,
    ExecutorSetClientContextCallback set_client_context,
    ExecutorGetClientContextCallback get_client_context,
    ExecutorDestroyCallback executor_destroy,
    RunnableRunCallback runnable_run,
    RunnableDestroyCallback runnable_destroy) {
  if (!(engine_shutdown && engine_destroy && buffer_create &&
        buffer_init_with_alloc && http_status_code_get && error_message_get &&
        http_status_text_get && upload_provider_get_client_context && create_with && 
        set_client_context && get_client_context &&
        executor_destroy && runnable_run && runnable_destroy)) {
    std::cerr << "Invalid pointer(s): null" << std::endl;
    return;
  }
  _Cronet_Engine_Shutdown = engine_shutdown;
  _Cronet_Engine_Destroy = engine_destroy;
  _Cronet_Buffer_Create = buffer_create;
  _Cronet_Buffer_InitWithAlloc = buffer_init_with_alloc;
  _Cronet_UrlResponseInfo_http_status_code_get = http_status_code_get;
  _Cronet_Error_message_get = error_message_get;
  _Cronet_UrlResponseInfo_http_status_text_get = http_status_text_get;
  _Cronet_UploadDataProvider_GetClientContext = upload_provider_get_client_context;
  _Cronet_Executor_CreateWith = create_with;
  _Cronet_Executor_SetClientContext = set_client_context;
  _Cronet_Executor_GetClientContext = get_client_context;
  _Cronet_Executor_Destroy = executor_destroy;
  _Cronet_Runnable_Run = runnable_run;
  _Cronet_Runnable_Destroy = runnable_destroy;
}

std::unordered_map<Cronet_UrlRequestPtr, Dart_Port> requestNativePorts;

void RegisterCallbackHandler(Dart_Port send_port, Cronet_UrlRequestPtr rp) {
  requestNativePorts[rp] = send_port;
}

static char *GetStatusText(Cronet_UrlResponseInfoPtr info, int statusCode,
    int lBound, int uBound) {
  if (statusCode >= lBound && statusCode <= uBound) {
    return nullptr;
  }
  Cronet_String status = _Cronet_UrlResponseInfo_http_status_text_get(info);
  return strdup(status);
}

static void HttpClientDestroy(void *isolate_callback_data, void *peer) {
  Cronet_EnginePtr ce = reinterpret_cast<Cronet_EnginePtr>(peer);
  if (_Cronet_Engine_Shutdown(ce) != Cronet_RESULT_SUCCESS) {
    std::cerr << "Failed to shut down the cronet engine." << std::endl;
    return;
  }
  _Cronet_Engine_Destroy(ce);
}

void RemoveRequest(Cronet_UrlRequestPtr rp) {
  requestNativePorts.erase(rp);
}

// Register our HttpClient object from dart side
void RegisterHttpClient(Dart_Handle h, Cronet_Engine *ce) {
  void *peer = ce;
  intptr_t size = 8;
  Dart_NewFinalizableHandle_DL(h, peer, size, HttpClientDestroy);
}

// This sends the callback name and the associated data with it to the Dart
// side via NativePort.
//
// Sent data is broken into 2 parts.
// message[0] is the method name, which is a string.
// message[1] contains all the data to pass to that method.
//
// Using this due to the lack of support for asynchronous callbacks in dart:ffi.
// See Issue: https://github.com/dart-lang/sdk/issues/37022.
static void DispatchCallback(const char *methodname, Cronet_UrlRequestPtr request,
                      Dart_CObject args) {
  Dart_CObject c_method_name;
  c_method_name.type = Dart_CObject_kString;
  c_method_name.value.as_string = const_cast<char *>(methodname);

  Dart_CObject *c_request_arr[] = {&c_method_name, &args};
  Dart_CObject c_request;

  c_request.type = Dart_CObject_kArray;
  c_request.value.as_array.values = c_request_arr;
  c_request.value.as_array.length =
      sizeof(c_request_arr) / sizeof(c_request_arr[0]);

  Dart_PostCObject_DL(requestNativePorts[request], &c_request);
}

static void FreeFinalizer(void *, void *value) { free(value); }

// Builds the arguments to pass to the Dart side as a parameter to the
// callbacks. [num] is the number of arguments to be passed and rest are the
// arguments.
static Dart_CObject CallbackArgBuilder(int num, ...) {
  Dart_CObject c_request_data;
  va_list valist;
  va_start(valist, num);
  void *request_buffer = malloc(sizeof(uint64_t) * num);
  uint64_t *buf = reinterpret_cast<uint64_t *>(request_buffer);

  // uintptr_r will get implicitly casted to uint64_t. So, when the code is
  // executed in 32 bit mode, the upper 32 bit of buf[i] will be 0 extended
  // automatically. This is required because, on the Dart side these addresses
  // are viewed as 64 bit integers.
  for (int i = 0; i < num; i++) {
    buf[i] = va_arg(valist, uintptr_t);
  }

  c_request_data.type = Dart_CObject_kExternalTypedData;
  c_request_data.value.as_external_typed_data.type = Dart_TypedData_kUint8;
  c_request_data.value.as_external_typed_data.length = sizeof(uint64_t) * num;
  c_request_data.value.as_external_typed_data.data =
      static_cast<uint8_t *>(request_buffer);
  c_request_data.value.as_external_typed_data.peer = request_buffer;
  c_request_data.value.as_external_typed_data.callback = FreeFinalizer;

  va_end(valist);

  return c_request_data;
}

void OnRedirectReceived(Cronet_UrlRequestCallbackPtr self,
                        Cronet_UrlRequestPtr request,
                        Cronet_UrlResponseInfoPtr info,
                        Cronet_String newLocationUrl) {
  fprintf(stderr, "%s:%d OnRedirectReceived\n", __FILE__, __LINE__);
  char *s = strdup(newLocationUrl);
  int result = _Cronet_UrlResponseInfo_http_status_code_get(info);
  // If NOT a 3XX status code.
  DispatchCallback("OnRedirectReceived", request,
                   CallbackArgBuilder(3, s, result,
                                      GetStatusText(info, result, 300, 399)));
  free(s);
}

void OnResponseStarted(Cronet_UrlRequestCallbackPtr self,
                       Cronet_UrlRequestPtr request,
                       Cronet_UrlResponseInfoPtr info) {
  fprintf(stderr, "%s:%d OnResponseStarted\n", __FILE__, __LINE__);
  // Create and allocate 32kb buffer.
  Cronet_BufferPtr buffer = _Cronet_Buffer_Create();
  _Cronet_Buffer_InitWithAlloc(buffer, 32 * 1024);
  int result = _Cronet_UrlResponseInfo_http_status_code_get(info);
  // If NOT a 1XX or 2XX status code.
  DispatchCallback("OnResponseStarted", request,
                   CallbackArgBuilder(4, result, info, buffer,
                                      GetStatusText(info, result, 100, 299)));
}

void OnReadCompleted(Cronet_UrlRequestCallbackPtr self,
                     Cronet_UrlRequestPtr request,
                     Cronet_UrlResponseInfoPtr info, Cronet_BufferPtr buffer,
                     uint64_t bytes_read) {
  fprintf(stderr, "%s:%d OnReadCompleted\n", __FILE__, __LINE__);
  int result = _Cronet_UrlResponseInfo_http_status_code_get(info);
  // If NOT a 1XX or 2XX status code.
  DispatchCallback("OnReadCompleted", request,
                   CallbackArgBuilder(6, request, info, result, buffer,
                                      bytes_read,
                                      GetStatusText(info, result, 100, 299)));
}

void OnSucceeded(Cronet_UrlRequestCallbackPtr self,
                 Cronet_UrlRequestPtr request, Cronet_UrlResponseInfoPtr info) {
  fprintf(stderr, "%s:%d OnSucceeded\n", __FILE__, __LINE__);
  int result = _Cronet_UrlResponseInfo_http_status_code_get(info);
  DispatchCallback("OnSucceeded", request, CallbackArgBuilder(2, result, info));
}

void OnFailed(Cronet_UrlRequestCallbackPtr self, Cronet_UrlRequestPtr request,
              Cronet_UrlResponseInfoPtr info, Cronet_ErrorPtr error) {
  fprintf(stderr, "%s:%d OnFailed\n", __FILE__, __LINE__);
  DispatchCallback("OnFailed", request, CallbackArgBuilder(1,
      strdup(_Cronet_Error_message_get(error))));
}

void OnCanceled(Cronet_UrlRequestCallbackPtr self, Cronet_UrlRequestPtr request,
                Cronet_UrlResponseInfoPtr info) {
  fprintf(stderr, "%s:%d OnCancelled\n", __FILE__, __LINE__);
  DispatchCallback("OnCanceled", request, CallbackArgBuilder(0));
}

// Implementation of Cronet_Executor interface using staticm methods to map
// C API into instance of C++ class.
// (based on https://chromium.googlesource.com/chromium/src/+/refs/heads/main/components/cronet/native/sample/sample_executor.h)
class CronetTaskExecutor {
 public:
  CronetTaskExecutor(): executor_thread_(CronetTaskExecutor::ThreadLoop, this) {}
  ~CronetTaskExecutor() {
    ShutdownExecutor();
    _Cronet_Executor_Destroy(executor_);
  }

  void Initialize() {
    executor_ = _Cronet_Executor_CreateWith(CronetTaskExecutor::Execute);
    _Cronet_Executor_SetClientContext(executor_, this);
  }

  // Gets Cronet_ExecutorPtr implemented by |this|.
  Cronet_ExecutorPtr GetExecutor() {
    return executor_;
  }

  // Shuts down the executor, so all pending tasks are destroyed without
  // getting executed.
  void ShutdownExecutor();

 private:
  // Runs tasks in |task_queue_| until |stop_thread_loop_| is set to true.
  void RunTasksInQueue();

  static void ThreadLoop(CronetTaskExecutor* executor) {
    executor->RunTasksInQueue();
  }

  void Execute(Cronet_RunnablePtr runnable);

  static void Execute(Cronet_ExecutorPtr self, Cronet_RunnablePtr runnable) {
    static_cast<CronetTaskExecutor *>(_Cronet_Executor_GetClientContext(self))->
        Execute(runnable);    
  }

  // Synchronise access to |task_queue_| and |stop_thread_loop_|;
  std::mutex lock_;
  // Tasks to run.
  std::queue<Cronet_RunnablePtr> task_queue_;
  // Notified if task is added to |task_queue_| or |stop_thread_loop_| is set.
  std::condition_variable task_available_;
  // Set to true to stop running tasks.
  bool stop_thread_loop_ = false;
  // Thread on which tasks are executed.
  std::thread executor_thread_;
  Cronet_ExecutorPtr executor_;
};

void CronetTaskExecutor::ShutdownExecutor() {
  // Break tasks loop.
  {
    std::lock_guard<std::mutex> lock(lock_);
    stop_thread_loop_ = true;
  }
  task_available_.notify_one();
  // Wait for executor thread.
  executor_thread_.join();
}

void CronetTaskExecutor::RunTasksInQueue() {
  // Process runnables in |task_queue_|.
  while (true) {
    Cronet_RunnablePtr runnable = nullptr;
    {
      // Wait for a task to run or stop signal.
      std::unique_lock<std::mutex> lock(lock_);
      while (task_queue_.empty() && !stop_thread_loop_) {
        task_available_.wait(lock);
      }
      if (stop_thread_loop_) {
        break;
      }
      if (task_queue_.empty()) {
        continue;
      }
      runnable = task_queue_.front();
      task_queue_.pop();
    }
    _Cronet_Runnable_Run(runnable);
    _Cronet_Runnable_Destroy(runnable);
  }
  // Delete remaining tasks.
  std::queue<Cronet_RunnablePtr> tasks_to_destroy;
  {
    std::unique_lock<std::mutex> lock(lock_);
    tasks_to_destroy.swap(task_queue_);
  }
  while (!tasks_to_destroy.empty()) {
    _Cronet_Runnable_Destroy(tasks_to_destroy.front());
    tasks_to_destroy.pop();
  }
}

void CronetTaskExecutor::Execute(Cronet_RunnablePtr runnable) {
  {
    std::lock_guard<std::mutex> lock(lock_);
    if (!stop_thread_loop_) {
      task_queue_.push(runnable);
      runnable = nullptr;
    }
  }
  if (runnable) {
    _Cronet_Runnable_Destroy(runnable);
  } else {
    task_available_.notify_one();
  }
}

CronetTaskExecutorPtr CronetTaskExecutorCreate() {
  return new CronetTaskExecutor();
}

void CronetTaskExecutorDestroy(CronetTaskExecutorPtr executor) {
  if (executor == nullptr) {
    std::cerr << "Invalid executor pointer: null." << std::endl;
    return;
  }
  delete executor;
}

void InitCronetTaskExecutor(CronetTaskExecutorPtr self) {
  self->Initialize();
}

// Cronet_ExecutorPtr of the provided CronetTaskExecutor.
Cronet_ExecutorPtr CronetTaskExecutor_Cronet_ExecutorPtr_get(
    CronetTaskExecutorPtr self) {
  return self->GetExecutor();
}

//
// This class encapsulates one upload request.
// 
class UploadDataProvider {
 public:
  void Initialize(int64_t length, Cronet_UrlRequestPtr request) {
    length_ = length;
    request_ = request;
  }
  void Read(Cronet_UploadDataSinkPtr upload_data_sink,
            Cronet_BufferPtr buffer) {
    DispatchCallback("Read", request_,
                     CallbackArgBuilder(2, upload_data_sink, buffer));
  }
  void Rewind(Cronet_UploadDataSinkPtr upload_data_sink) {
    DispatchCallback("Rewind", request_,
                     CallbackArgBuilder(1, upload_data_sink));
  }
  void Close() {
    DispatchCallback("Close", request_, CallbackArgBuilder(1, this));    
  }
  // Gets the length of the data to be uploaded.
  int64_t GetLength() { return length_; }

 private:
  int64_t length_ = 0;
  Cronet_UrlRequestPtr request_;
};

UploadDataProviderPtr UploadDataProviderCreate() {
  return new UploadDataProvider();
}
void UploadDataProviderDestroy(UploadDataProviderPtr upload_data_provider) {
  delete upload_data_provider;
}
void UploadDataProviderInit(UploadDataProviderPtr self, int64_t length,
                            Cronet_UrlRequestPtr request) {
  fprintf(stderr, "%s:%d UploadDataProviderInit self: %p length: %ld, request:%p\n", __FILE__, __LINE__,
      self, length, request);
  self->Initialize(length, request);
}

int64_t UploadDataProvider_GetLength(Cronet_UploadDataProviderPtr self) {
  int64_t result = static_cast<UploadDataProviderPtr>(
      _Cronet_UploadDataProvider_GetClientContext(self))->GetLength();
  fprintf(stderr, "%s:%d GetLength for self: %p returns %ld\n", __FILE__, __LINE__,
      self, result);
  return result;
}
void UploadDataProvider_Read(Cronet_UploadDataProviderPtr self,
                             Cronet_UploadDataSinkPtr upload_data_sink,
                             Cronet_BufferPtr buffer) {
  fprintf(stderr, "%s:%d Read for self: %p sink: %p, buffer: %p\n", __FILE__, __LINE__,
      self, upload_data_sink, buffer);
  static_cast<UploadDataProviderPtr>(
      _Cronet_UploadDataProvider_GetClientContext(self))->Read(
          upload_data_sink, buffer);
}
void UploadDataProvider_Rewind(Cronet_UploadDataProviderPtr self,
                               Cronet_UploadDataSinkPtr upload_data_sink) {
  fprintf(stderr, "%s:%d Rewind for self: %p sink: %p\n", __FILE__, __LINE__, 
      self, upload_data_sink);
  static_cast<UploadDataProviderPtr>(
      _Cronet_UploadDataProvider_GetClientContext(self))->Rewind(
          upload_data_sink);
}
void UploadDataProvider_Close(Cronet_UploadDataProviderPtr self) {
  fprintf(stderr, "%s:%d Close for self: %p\n", __FILE__, __LINE__, self);
  static_cast<UploadDataProviderPtr>(
      _Cronet_UploadDataProvider_GetClientContext(self))->Close();
}

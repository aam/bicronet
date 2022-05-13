// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
#ifndef CRONET_DART_API_H
#define CRONET_DART_API_H

#include <stdbool.h>
#include <stdint.h>

#include "../third_party/cronet/cronet.idl_c.h"
#include "../third_party/dart/dart_api_dl.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct CronetTaskExecutor *CronetTaskExecutorPtr;
typedef struct UploadDataProvider *UploadDataProviderPtr;

#if defined(WIN32)
#define EXPORT __declspec(dllexport)
#else
#define EXPORT __attribute__((visibility("default")))
#endif

//
// Initialization
//
EXPORT intptr_t InitDartApiDL(void *data);

typedef Cronet_RESULT (*EngineShutdownCallback)(Cronet_EnginePtr self);
typedef void (*EngineDestroyCallback)(Cronet_EnginePtr self);
typedef Cronet_BufferPtr (*BufferCreateCallback)(void);
typedef void (*BufferInitWithAllocCallback)(Cronet_BufferPtr self,
    uint64_t size);
typedef int32_t (*UrlResponseInfoHttpStatusCodeGetCallback)(
    const Cronet_UrlResponseInfoPtr self);
typedef Cronet_String (*ErrorMessageGetCallback)(const Cronet_ErrorPtr self);
typedef Cronet_String (*UrlResponseInfoHttpStatusTextGetCallback)(
    const Cronet_UrlResponseInfoPtr self);
typedef Cronet_ClientContext (*UploadDataProviderGetClientContextCallback)(
    Cronet_UploadDataProviderPtr self);
typedef Cronet_ExecutorPtr (*ExecutorCreateWithCallback)(
    Cronet_Executor_ExecuteFunc);
typedef  void (*ExecutorSetClientContextCallback)(Cronet_ExecutorPtr self,
    Cronet_ClientContext client_context);
typedef Cronet_ClientContext (*ExecutorGetClientContextCallback)(
    Cronet_ExecutorPtr self);
typedef void (*ExecutorDestroyCallback)(Cronet_ExecutorPtr self);
typedef void (*RunnableRunCallback)(Cronet_RunnablePtr self);
typedef void (*RunnableDestroyCallback)(Cronet_RunnablePtr self);

EXPORT void InitCronetDartApi(
    EngineShutdownCallback engine_shutdown,
    EngineDestroyCallback engine_destroy,
    BufferCreateCallback buffer_create,
    BufferInitWithAllocCallback  buffer_init_with_alloc,
    UrlResponseInfoHttpStatusCodeGetCallback status_code_get,
    ErrorMessageGetCallback error_message_get,
    UrlResponseInfoHttpStatusTextGetCallback http_status_text_get,
    UploadDataProviderGetClientContextCallback
        upload_provider_get_client_context,
    ExecutorCreateWithCallback create_with,
    ExecutorSetClientContextCallback set_client_context,
    ExecutorGetClientContextCallback get_client_context,
    ExecutorDestroyCallback executor_destroy,
    RunnableRunCallback runnable_run,
    RunnableDestroyCallback runnable_destroy);

EXPORT void RegisterHttpClient(Dart_Handle h, Cronet_Engine *ce);
EXPORT void RegisterCallbackHandler(Dart_Port nativePort,
                                    Cronet_UrlRequest *rp);
EXPORT void RemoveRequest(Cronet_UrlRequest *rp);

//
// Callbacks
//
EXPORT void OnRedirectReceived(Cronet_UrlRequestCallbackPtr self,
                               Cronet_UrlRequestPtr request,
                               Cronet_UrlResponseInfoPtr info,
                               Cronet_String newLocationUrl);

EXPORT void OnResponseStarted(Cronet_UrlRequestCallbackPtr self,
                              Cronet_UrlRequestPtr request,
                              Cronet_UrlResponseInfoPtr info);

EXPORT void OnReadCompleted(Cronet_UrlRequestCallbackPtr self,
                            Cronet_UrlRequestPtr request,
                            Cronet_UrlResponseInfoPtr info,
                            Cronet_BufferPtr buffer,
                            uint64_t bytes_read);

EXPORT void OnSucceeded(Cronet_UrlRequestCallbackPtr self,
                        Cronet_UrlRequestPtr request,
                        Cronet_UrlResponseInfoPtr info);

EXPORT void OnFailed(Cronet_UrlRequestCallbackPtr self,
                     Cronet_UrlRequestPtr request,
                     Cronet_UrlResponseInfoPtr info,
                     Cronet_ErrorPtr error);

EXPORT void OnCanceled(Cronet_UrlRequestCallbackPtr self,
                       Cronet_UrlRequestPtr request,
                       Cronet_UrlResponseInfoPtr info);

//
// Task executor
//
EXPORT CronetTaskExecutorPtr CronetTaskExecutorCreate();
EXPORT void CronetTaskExecutorDestroy(CronetTaskExecutorPtr executor);

EXPORT void InitCronetTaskExecutor(CronetTaskExecutorPtr self);
EXPORT Cronet_ExecutorPtr CronetTaskExecutor_Cronet_ExecutorPtr_get(
    CronetTaskExecutorPtr self);

//
// Upload data provider
//
EXPORT UploadDataProviderPtr UploadDataProviderCreate();
EXPORT void UploadDataProviderDestroy(UploadDataProviderPtr upload_data_provided);
EXPORT void UploadDataProviderInit(UploadDataProviderPtr self, int64_t length,
                                   Cronet_UrlRequestPtr request);

EXPORT int64_t UploadDataProvider_GetLength(Cronet_UploadDataProviderPtr self);
EXPORT void UploadDataProvider_Read(Cronet_UploadDataProviderPtr self,
                                    Cronet_UploadDataSinkPtr upload_data_sink,
                                    Cronet_BufferPtr buffer);
EXPORT void UploadDataProvider_Rewind(Cronet_UploadDataProviderPtr self,
    Cronet_UploadDataSinkPtr upload_data_sink);
EXPORT void UploadDataProvider_Close(Cronet_UploadDataProviderPtr self);


#ifdef __cplusplus
}
#endif

#endif // CRONET_DART_API_H

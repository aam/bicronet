cmake_minimum_required(VERSION 3.10)
set(PROJECT_NAME "cronet_dart")
project(${PROJECT_NAME} LANGUAGES C CXX)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

#!android set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD 11)

set(PLUGIN_NAME "cronet_dart")

add_definitions(-DDART_SHARED_LIB)

add_library(${PLUGIN_NAME} SHARED
  "bicronet_dart_api.cc"
  "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/dart/dart_api_dl.c"
)

add_executable("cronet_dart_test"
  "cronet_dart_test.cc")

set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)

target_include_directories(${PLUGIN_NAME} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}"
  "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/dart"
  "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/dart/runtime"
  "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/cronet"
  "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/grpc_support"
)

target_include_directories("cronet_dart_test" PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/grpc_support"
)

add_library("cronet.104.0.5108.0" SHARED IMPORTED)

if(DEFINED CMAKE_ANDROID_ARCH_ABI)
  add_library("log" SHARED IMPORTED)
  add_library("android" SHARED IMPORTED)
  set_target_properties("cronet.104.0.5108.0" PROPERTIES IMPORTED_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/../libs/${CMAKE_ANDROID_ARCH_ABI}/libcronet.104.0.5108.0.so")
  set_target_properties("log" PROPERTIES IMPORTED_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/../libs/${CMAKE_ANDROID_ARCH_ABI}/liblog.so")
  set_target_properties("android" PROPERTIES IMPORTED_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/../libs/${CMAKE_ANDROID_ARCH_ABI}/libandroid.so")
  target_link_libraries(${PLUGIN_NAME} "cronet.104.0.5108.0" "log")
  target_link_libraries("cronet_dart_test" "cronet.104.0.5108.0" "log")
  message(STATUS "CMAKE_ANDROID_ARCH_ABI: ${CMAKE_ANDROID_ARCH_ABI}")
  if(CMAKE_ANDROID_ARCH_ABI STREQUAL "arm64-v8a")
    target_link_libraries(${PLUGIN_NAME} "android")
    target_link_libraries("cronet_dart_test" "android")
  endif()
else()
  set_target_properties("cronet.104.0.5108.0" PROPERTIES IMPORTED_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/../../.dart_tool/out/libcronet.104.0.5108.0.so")
  target_link_libraries(${PLUGIN_NAME} "cronet.104.0.5108.0")
  target_link_libraries("cronet_dart_test" "cronet.104.0.5108.0")
endif()



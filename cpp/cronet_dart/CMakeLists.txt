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
#  "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/cronet"
#  "/usr/local/google/home/aam/p/ch/src"
#  "/usr/local/google/home/aam/p/ch/src/third_party/abseil-cpp"
#  "/usr/local/google/home/aam/p/ch/src/net/cert"
#  "/usr/local/google/home/aam/p/ch/src/net/third_party/quiche/src"
#  "/usr/local/google/home/aam/p/ch/src/net/third_party/quiche/overrides"
#  "/usr/local/google/home/aam/p/ch/src/net/third_party/quiche/src/quiche/common/platform/default"
#  "/usr/local/google/home/aam/p/ch/src/third_party/boringssl/src/include"
#  "/usr/local/google/home/aam/p/ch/src/out/Default/gen"
)

add_library("cronet.103.0.5019.0" SHARED IMPORTED)

if(DEFINED CMAKE_ANDROID_ARCH_ABI)
  add_library("log" SHARED IMPORTED)
  set_target_properties("cronet.103.0.5019.0" PROPERTIES IMPORTED_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/../libs/${CMAKE_ANDROID_ARCH_ABI}/libcronet.102.0.4973.2.so")
  set_target_properties("log" PROPERTIES IMPORTED_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/../libs/${CMAKE_ANDROID_ARCH_ABI}/liblog.so")
  target_link_libraries(${PLUGIN_NAME} "cronet.103.0.5019.0" "log")
else()
  set_target_properties("cronet.103.0.5019.0" PROPERTIES IMPORTED_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/../../.dart_tool/out/libcronet.103.0.5019.0.so")
  target_link_libraries(${PLUGIN_NAME} "cronet.103.0.5019.0")
endif()

target_link_libraries("cronet_dart_test" "cronet.103.0.5019.0")


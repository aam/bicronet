cmake_minimum_required(VERSION 3.10)
set(PROJECT_NAME "cronet_dart")
project(${PROJECT_NAME} LANGUAGES C CXX)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_STANDARD 11)

set(PLUGIN_NAME "cronet_dart")

add_compile_definitions(DART_SHARED_LIB)

add_library(${PLUGIN_NAME} SHARED
  "cronet_dart_api.cc"
  "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/dart/dart_api_dl.c"
)

set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)

target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}"
  "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/dart"
  "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/dart/runtime"
  "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/cronet"

)

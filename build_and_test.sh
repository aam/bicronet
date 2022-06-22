#!/bin/zsh
set -x
set -e

#
# CH - chromium
# BC - bicronet
#

CH=${CH:-$HOME/p/ch/src}
BC=${BC:-$HOME/p/bicronet}

cd $CH
./components/cronet/tools/cr_cronet.py gn --out_dir=out/AndroidRelease --args="is_component_build=false is_debug=false is_official_build=true"
ninja -C out/AndroidRelease cronet_package
./components/cronet/tools/cr_cronet.py gn --out_dir=out/AndroidX86 --args="target_cpu="x86" is_component_build=false is_debug=true is_official_build=false" 
ninja -C out/AndroidX86 cronet_package
./components/cronet/tools/cr_cronet.py gn --out_dir=out/AndroidARM64 --args='is_component_build=false is_debug=true is_official_build=false'
echo 'target_cpu = "arm64"' >> out/AndroidARM64/args.gn
ninja -C out/Android64 cronet_package
gn gen out/Debug --args='use_goma=true is_component_build=false is_debug=true is_official_build=false'
ninja -C out/Debug cronet_package

mkdir -p $BC/.dart_tool/out
cp $CH/out/AndroidRelease/libcronet.103.0.5019.0.so $BC/cpp/libs/armeabi-v7a/libcronet.102.0.4973.2.so
cp $CH/out/AndroidX86/libcronet.103.0.5019.0.so $BC/cpp/libs/x86/libcronet.102.0.4973.2.so
cp $CH/out/Android64/libcronet.103.0.5019.0.so $BC/cpp/libs/arm64-v8a/libcronet.102.0.4973.2.so
cp $CH/out/Debug/libcronet.103.0.5019.0.so $BC/.dart_tool/out/libcronet.102.0.4973.2.so

cd $BC 
cmake cpp/cronet_dart/CMakeLists.txt -B $BC/.dart_tool/out -DCMAKE_BUILD_TYPE=Release 
$DH/out/ReleaseX64/dart-sdk/bin/dart run ffigen --config lib/src/cpp/cronet_dart/ffigen.yaml 
$DH/out/ReleaseX64/dart-sdk/bin/dart run ffigen --config lib/src/cpp/grpc_support/ffigen.yaml 
$DH/out/ReleaseX64/dart-sdk/bin/dart run ffigen --config lib/src/cpp/cronet/ffigen.yaml 
cmake --build $BC/.dart_tool/out 

~/p/d/dart-sdk1/sdk/out/ReleaseX64/dart-sdk/bin/dart test/bicronet_grpc_test.dart

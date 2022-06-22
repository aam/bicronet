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
./components/cronet/tools/cr_cronet.py gn --out_dir=out/AndroidX86 --args="is_component_build=false is_debug=true is_official_build=false"
echo 'target_cpu="x86" ' >> out/AndroidX86/args.gn
ninja -C out/AndroidX86 cronet_package
./components/cronet/tools/cr_cronet.py gn --out_dir=out/AndroidARM64 --args='is_component_build=false is_debug=true is_official_build=false'
echo 'target_cpu = "arm64"' >> out/AndroidARM64/args.gn
ninja -C out/AndroidARM64 cronet_package
gn gen out/Debug --args='use_goma=true is_component_build=false is_debug=true is_official_build=false'
ninja -C out/Debug cronet_package

mkdir -p $BC/.dart_tool/out
cp $CH/out/AndroidRelease/libcronet.*.so $BC/cpp/libs/armeabi-v7a/
cp $CH/out/AndroidX86/libcronet.*.so $BC/cpp/libs/x86/
cp $CH/out/AndroidARM64/libcronet.*.so $BC/cpp/libs/arm64-v8a/
cp $CH/out/Debug/libcronet.*.so $BC/.dart_tool/out/

cd $BC 
cmake cpp/cronet_dart/CMakeLists.txt -B $BC/.dart_tool/out -DCMAKE_BUILD_TYPE=Release 
$DH/out/ReleaseX64/dart-sdk/bin/dart run ffigen --config lib/src/cpp/cronet_dart/ffigen.yaml 
$DH/out/ReleaseX64/dart-sdk/bin/dart run ffigen --config lib/src/cpp/grpc_support/ffigen.yaml 
$DH/out/ReleaseX64/dart-sdk/bin/dart run ffigen --config lib/src/cpp/cronet/ffigen.yaml 
cmake --build $BC/.dart_tool/out 

~/p/d/dart-sdk1/sdk/out/ReleaseX64/dart-sdk/bin/dart test/bicronet_grpc_test.dart

cd android
$BC/android/gradlew build

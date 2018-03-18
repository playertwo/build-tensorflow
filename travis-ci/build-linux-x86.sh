#!/bin/bash

os_name="linux"
tf_type="cpu"
tf_tag_name="r1.6"
tf_version="1.6.0"
platform_name="x86"


apt update
apt -y --force-yes install \
  build-essential \
  cmake \
  git \
  python3 \
  wget \
  zip

cd /build-tensorflow
git clone https://github.com/tensorflow/tensorflow
cd tensorflow && git checkout $tf_tag_name
wget --output-document=../patches/fix_grpc_build_linux.patch https://github.com/tensorflow/tensorflow/commit/462756fcb33e2dd7c6f5132459612442d36d8476.patch
git apply ../patches/fix_grpc_build_linux.patch
git apply ../patches/add-ops.patch
mkdir build && cd build
cmake ../tensorflow/contrib/cmake -DCMAKE_BUILD_TYPE=Release -Dtensorflow_BUILD_CC_EXAMPLE=OFF -Dtensorflow_BUILD_PYTHON_BINDINGS=OFF -Dtensorflow_BUILD_SHARED_LIB=ON -Dtensorflow_BUILD_CONTRIB_KERNELS=OFF -Dtensorflow_OPTIMIZE_FOR_NATIVE_ARCH=OFF -Dtensorflow_DISABLE_EIGEN_FORCEINLINE=ON -Dtensorflow_ENABLE_GRPC_SUPPORT=OFF -Dtensorflow_BUILD_ALL_KERNELS=OFF
cmake --build . --config Release -- -j 8


mkdir -p /build-tensorflow/artifacts
zip -r -X /build-tensorflow/artifacts/libtensorflow-$tf_type-$os_name-$platform_name-$tf_version.zip libtensorflow.so

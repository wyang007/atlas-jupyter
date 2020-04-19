#!/bin/sh

# Compile and install ROOT 6.12.06.
# Require: cmake 3.12 or higher.
# This script should be run in an environment where ROOT be used, such as inside a container.

roottarball="root_v6.12.06.source.tar.gz"
rootinstdir="/mycvmfs/pkgs/root-6.12.06"

wget --quiet https://root.cern.ch/download/$roottarball -O /tmp/rootsource.tar.gz && \
tar -zxf /tmp/rootsource.tar.gz --directory=/tmp
mkdir -p /tmp/root-6.12.06/rootbuild 
cd /tmp/root-6.12.06/rootbuild 
cmake3 -j 4 \
    -Dxml:BOOL=ON \
    -Dvdt:BOOL=OFF \
    -Dbuiltin_fftw3:BOOL=ON \
    -Dfitsio:BOOL=OFF \
    -Dfftw:BOOL=ON \
    -Dbuiltin_xroot=ON \
    -Dbuiltin_davix=ON \
    -DCMAKE_INSTALL_PREFIX:PATH=$rootinstdir \
    -Dpython3=ON \
    -Dpython=ON \
    -DPYTHON_EXECUTABLE:PATH=/bin/python3 \
    ..
#    -DPYTHON_INCLUDE_DIR:PATH=/usr/include/python3.6m \
#    -DPYTHON_LIBRARY:PATH=/opt/rh/rh-python36/root/usr/lib64/libpython3.6m.so \

source /tmp/root-6.12.06/rootbuild/bin/thisroot.sh 
cd /tmp/root-6.12.06/rootbuild 
cmake3 --build . --target install -- -j 8
rm -r /tmp/rootsource.tar.gz /tmp/root-6.12.06

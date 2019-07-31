FROM slaclab/atlas-jupyterlab-pyroot:v003 as intermediate
USER root

FROM slaclab/slac-jupyterlab:20190610.2
USER root

WORKDIR /packages

## Install dependencies for Boost and ROOT
RUN	yum install -y libcurl-devel mysql-devel net-tools sudo centos-release-scl \
	make wget git patch gcc-c++ gcc binutils libX11-devel libXpm-devel libXft-devel \
	libXext-devel gcc-gfortran openssl-devel pcre-devel mesa-libGL-devel \
	mesa-libGLU-devel glew-devel mysql-devel fftw-devel graphviz-devel \
	avahi-compat-libdns_sd-devel python-devel libxml2-devel gls-devel blas-devel \
	bazel http-parser nodejs perl-Digest-MD5 zlib-devel perl-ExtUtils-MakeMaker gettext \
	libffi-devel pandoc texlive texlive-collection-xetex texlive-ec texlive-upquote \
	texlive-adjustbox emacs bzip2 zip unzip lrzip tree ack screen tmux vim-enhanced emacs-nox \
	libarchive-devel fuse-sshfs jq graphviz \
	dvipng cmake xterm \ 
        xrootd-client xrootd-client-lib xrootd-client-devel davix davix-devel rclone \
	&& yum clean all

COPY --from=intermediate /packages/root6.12/ /packages/root6.12/

### install cmake 3.12 (required to build ROOT 6)
#RUN yum remove cmake # removes cmake command conflict
#RUN wget --quiet https://cmake.org/files/v3.12/cmake-3.12.0-rc3.tar.gz -O /tmp/cmake.tar.gz && \
#	tar -zxf /tmp/cmake.tar.gz --directory=/tmp  && cd /tmp/cmake-3.12.0-rc3/ && \
#	./bootstrap && \
#	make -j 4  && make install && \
#	rm -r /tmp/cmake.tar.gz /tmp/cmake-3.12.0-rc3 
#
### install ROOT 6.12
#RUN wget --quiet https://root.cern.ch/download/root_v6.12.06.source.tar.gz -O ~/rootsource.tar.gz && \
#	tar -zxf ~/rootsource.tar.gz --directory=$HOME
#RUN source scl_source enable rh-python36 && \
#	mkdir -p $HOME/root-6.12.06/rootbuild && cd $HOME/root-6.12.06/rootbuild && \
#	cmake -j 4 \
#	-Dxml:BOOL=ON \
#	-Dvdt:BOOL=OFF \
#	-Dbuiltin_fftw3:BOOL=ON \
#	-Dfitsio:BOOL=OFF \
#	-Dfftw:BOOL=ON \
#	-Dbuiltin_xroot=ON \
#	-Dbuiltin_davix=ON \
#	-DCMAKE_INSTALL_PREFIX:PATH=/packages/root6.12 \
#	-Dpython3=ON \
#	-Dpython=ON \
#	-DPYTHON_EXECUTABLE:PATH=/opt/rh/rh-python36/root/usr/bin/python \
#	-DPYTHON_INCLUDE_DIR:PATH=/opt/rh/rh-python36/root/usr/include/python3.6m \
#	-DPYTHON_LIBRARY:PATH=/opt/rh/rh-python36/root/usr/lib64/libpython3.6m.so \
#	..  
#RUN source $HOME/root-6.12.06/rootbuild/bin/thisroot.sh && \
#	cd $HOME/root-6.12.06/rootbuild && \
#	cmake --build . --target install -- -j 8
#RUN rm -r ~/rootsource.tar.gz ~/root-6.12.06

## Install additional Python modules
RUN source /packages/root6.12/bin/thisroot.sh && \
	source scl_source enable rh-python36 && \
	pip install --upgrade pip && \
	pip --no-cache-dir install \
	root_numpy \
	uproot \
	h5py \
	iminuit \
	tensorflow \ 
	pydot \
	keras \
	jupyter \
	metakernel \
	zmq \
	dask[complete] \
	xlrd xlwt openpyxl 
     
### Finalize environment
#

## Copy update launch.bash to source ROOT in jupyter python notebooks 
COPY hooks/launch.bash-with-root /opt/slac/jupyterlab/launch.bash
COPY hooks/launch.bash-with-jupyroot /opt/slac/jupyterlab/launch.bash-with-jupyroot

## Rename SLAC_Stack jupyter kernel
COPY kernels/rename-slac-stack /usr/local/share/jupyter/kernels/slac_stack/kernel.json 

## Add ROOT C++ kernel
RUN mkdir /usr/local/share/jupyter/kernels/jupyroot
RUN cp /packages/root6.12/etc/notebook/kernels/root/logo-64x64.png /usr/local/share/jupyter/kernels/jupyroot
COPY kernels/rename-jupyroot /usr/local/share/jupyter/kernels/jupyroot/kernel.json

## allow arrow key navigation in terminal vim
RUN echo 'set term=builtin_ansi' >> /etc/vimrc

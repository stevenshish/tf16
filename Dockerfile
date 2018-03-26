FROM ubuntu:16.04

# add repository with recent versions of compilers
RUN apt-get -y update \
  && apt-get -y clean \
  && apt-get -y install software-properties-common \
  && add-apt-repository -y ppa:ubuntu-toolchain-r/test \
  && apt-get -y clean

# install requirements
RUN apt-get -y update \
  && apt-get -y install \
       build-essential \
       curl \
       git \
       cmake \
       unzip \
       autoconf \
       autogen \
       libtool \
       mlocate \
       zlib1g-dev \
       g++-6 \
       python \
       python3-numpy \
       python3-dev \
       python3-pip \
       python3-wheel \
       wget \
       vim \
       ssh \
  && apt-get -y clean \
  && rm -rf /var/lib/apt/lists/* \
           /tmp/* \
           /var/tmp/*

# when building TF with Intel MKL support, `locate` database needs to exist
RUN updatedb

# install bazel for the shared library version
RUN echo "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list
RUN curl https://bazel.build/bazel-release.pub.gpg | apt-key add -
RUN apt-get -y update \
 && apt-get -y install openjdk-8-jdk bazel \
 && apt-get -y clean

# copy the contents of this repository to the container
 RUN git clone https://github.com/FloopCZ/tensorflow_cc.git

# install tensorflow
RUN mkdir /tensorflow_cc/tensorflow_cc/build
WORKDIR /tensorflow_cc/tensorflow_cc/build
# configure only shared or only static library

RUN cmake -DTENSORFLOW_STATIC=OFF -DTENSORFLOW_SHARED=ON .. \
  # build
  && make \
  # cleanup after bazel
  && rm -rf ~/.cache \
  # install
  && make install



RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y remove x264 libx264-dev && \
    apt-get -y install build-essential checkinstall cmake pkg-config yasm gfortran git && \
    apt-get -y install libjpeg8-dev libjasper-dev libpng12-dev && \
    apt-get -y install libtiff5-dev && \
    apt-get -y install libavcodec-dev libavformat-dev libswscale-dev libdc1394-22-dev && \
    apt-get -y install libxine2-dev libv4l-dev && \
    apt-get -y install libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev && \
    apt-get -y install libqt4-dev libgtk2.0-dev libtbb-dev && \
    apt-get -y install libatlas-base-dev && \
    apt-get -y install libfaac-dev libmp3lame-dev libtheora-dev && \
    apt-get -y install libvorbis-dev libxvidcore-dev && \
    apt-get -y install libopencore-amrnb-dev libopencore-amrwb-dev && \
    apt-get -y install x264 v4l-utils && \
    apt-get -y install libprotobuf-dev protobuf-compiler && \
    apt-get -y install libgoogle-glog-dev libgflags-dev && \
    apt-get -y install libgphoto2-dev libeigen3-dev libhdf5-dev doxygen && \
    apt-get -y install python-dev python-pip python3-dev python3-pip && \
    pip2 install -U pip numpy && \
    pip3 install -U pip numpy && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
           /tmp/* \
           /var/tmp/*

RUN mkdir ~/opencv
RUN cd ~/opencv && git clone https://github.com/Itseez/opencv_contrib.git
RUN cd ~/opencv && git clone https://github.com/Itseez/opencv.git

# 如果不支持cuda，移除 -D WITH_CUDA=ON
RUN cd ~/opencv/opencv && mkdir build && cd build && \
          cmake -D CMAKE_BUILD_TYPE=RELEASE \
	  -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D INSTALL_C_EXAMPLES=ON \
          -D INSTALL_PYTHON_EXAMPLES=ON \
          -D WITH_TBB=ON \
          -D WITH_V4L=ON \
          -D WITH_QT=ON \
          -D WITH_OPENGL=ON \
          -D WITH_CUDA=ON \
          -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
          -D BUILD_EXAMPLES=ON ..

RUN cd ~/opencv/opencv/build && make -j $(nproc) && make install
RUN sh -c 'echo "/usr/local/lib" >> /etc/ld.so.conf.d/opencv.conf'
RUN ldconfig


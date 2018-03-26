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
 RUN git clone https://github.com/stevenshish/tensorflow_cc.git

# install tensorflow
RUN mkdir /tensorflow_cc/tensorflow_cc/build
WORKDIR /tensorflow_cc/tensorflow_cc/build
RUN cd 
# configure only shared or only static library

RUN cmake -DTENSORFLOW_STATIC=OFF -DTENSORFLOW_SHARED=ON .. \
  # build
  && make \
  # cleanup after bazel
  && rm -rf ~/.cache \
  # install
  && make install



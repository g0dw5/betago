# Adapted from https://github.com/gw0/docker-keras-full
# docker-debian-cuda - Debian 9 with CUDA Toolkit

FROM gw000/keras:2.0.2-gpu
MAINTAINER gw0 [http://gw.tnode.com/] <gw.2017@ena.one>

# install py2-th-cpu (Python 2, Theano, CPU/GPU)
ARG THEANO_VERSION=0.9.0
ENV THEANO_FLAGS='device=cpu,floatX=float32'
RUN pip --no-cache-dir install git+https://github.com/Theano/Theano.git@rel-${THEANO_VERSION}

# install py3-tf-cpu/gpu (Python 3, TensorFlow, CPU/GPU)
RUN apt-get update -qq \
 && apt-get install --no-install-recommends -y --allow-unauthenticated \
    # install python 3
    python3 \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-virtualenv \
    pkg-config \
    # requirements for numpy
    libopenblas-base \
    python3-numpy \
    python3-scipy \
    # requirements for keras
    python3-h5py \
    python3-yaml \
    python3-pydot \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# 版本不能太高了
RUN pip3 install protobuf==3.6.1

ARG TENSORFLOW_VERSION=1.0.1
ARG TENSORFLOW_DEVICE=gpu
ARG TENSORFLOW_APPEND=_gpu
RUN pip3 --no-cache-dir install https://storage.googleapis.com/tensorflow/linux/${TENSORFLOW_DEVICE}/tensorflow${TENSORFLOW_APPEND}-${TENSORFLOW_VERSION}-cp35-cp35m-linux_x86_64.whl

ARG KERAS_VERSION=2.0.2
ENV KERAS_BACKEND=tensorflow
RUN pip3 --no-cache-dir install git+https://github.com/fchollet/keras.git@${KERAS_VERSION}

# install py3-th-cpu/gpu (Python 3, Theano, CPU/GPU)
ARG THEANO_VERSION=0.9.0
ENV THEANO_FLAGS='device=cpu,floatX=float32'
RUN pip3 --no-cache-dir install git+https://github.com/Theano/Theano.git@rel-${THEANO_VERSION}

# install additional debian packages
RUN apt-get update -qq \
 && apt-get install --no-install-recommends -y --allow-unauthenticated \
    # system tools
    less \
    procps \
    vim-tiny \
    # build dependencies
    build-essential \
    libffi-dev \
    # 需要配置字符集,不然读取资源报乱码
    locales \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Copy application to container
RUN mkdir -p app
WORKDIR /app
COPY . /app

# Install requirements
# protobuf版本不能太高
RUN pip install -i https://pypi.tuna.tsinghua.edu.cn/simple protobuf==3.6.1
RUN pip install -i https://pypi.tuna.tsinghua.edu.cn/simple -r requirements.txt

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Expose default port and start app
EXPOSE 8080
ENTRYPOINT ["python", "run_demo.py"]

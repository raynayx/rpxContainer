FROM fedora:40

ENV REFRESHED_AT=2025-01-28

# Add timezone info  
ENV TZ=Africa/Accra

# Update base
RUN dnf update -y

# Install g++ and dependencies
RUN dnf install -y \
    g++ \
    wget \
    git  \
    python3-pip\
    python3-invoke \
    cmake \
    vim \
    ninja-build \
    xz &&\
    #
    # JLink dependencies 
    #
    dnf install -y libXrandr \
    libXfixes \
    libXcursor \
    ncurses-compat-libs &&\
    dnf clean all

ARG MAIN_USER=rpx
ARG MAIN_HOME=/home/${MAIN_USER}


RUN useradd -m ${MAIN_USER}

#Download JLink_V812d.rpm
# RUN curl -o ${MAIN_HOME}/opt/JLink.rpm --data "accept_license_agreement=accepted" https://www.segger.com/downloads/jlink/JLink_Linux_x86_64.rpm
ARG JLINK_BIN=JLink.rpm
COPY ${JLINK_BIN} ${MAIN_HOME}/opt/

#install JLink tools
RUN cd ${MAIN_HOME}/opt/ &&\
    dnf install -y --disablerepo=* ./${JLINK_BIN} &&\
    rm ${JLINK_BIN}

  
# Download and install RP2040 Toolchains
# RUN curl -o ~/opt/arm-none-eabi-14.tar.xz \
# https://developer.arm.com/-/media/Files/downloads/gnu/14.2.rel1/binrel/arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-eabi.tar.xz

#Copy and install arm-none-eabi-toolchain
COPY arm-none-eabi-14.tar.xz ${MAIN_HOME}/opt/
RUN cd ${MAIN_HOME}/opt/ && \
    tar -xf arm-none-eabi-14.tar.xz &&\
    mv arm-gnu-toolchain-* arm-none-eabi/ &&\
    rm ./arm-none-eabi-* 

ENV PATH=$PATH:${MAIN_HOME}/opt/arm-none-eabi/bin/


# Clone and setup the RP2040(PICO) SDK
RUN git clone https://github.com/raspberrypi/pico-sdk ${MAIN_HOME}/opt/pico-sdk/

RUN cd ${MAIN_HOME}/opt/pico-sdk/ &&\
    git submodule update --init

# get, build and install picotool
RUN git clone https://github.com/raspberrypi/picotool.git ${MAIN_HOME}/opt/picotool
RUN mkdir ${MAIN_HOME}/opt/picotool_bin
RUN cd ${MAIN_HOME}/opt/picotool/ &&\
    mkdir build
RUN cd ${MAIN_HOME}/opt/picotool/build &&\
    cmake -DCMAKE_INSTALL_PREFIX=${MAIN_HOME}/opt/picotool_bin/ \
    -DPICO_SDK_PATH=${MAIN_HOME}/opt/pico-sdk -DPICOTOOL_FLAT_INSTALL=1 .. 
RUN cd ${MAIN_HOME}/opt/picotool/build &&\
    make install

    

ENV PICO_SDK_PATH=${MAIN_HOME}/opt/pico-sdk/
ENV CMAKE_CXX_COMPILER=${MAIN_HOME}/opt/arm-none-eabi/bin/arm-none-eabi-g++

#Set the dev directory
WORKDIR ${MAIN_HOME}/dev/

USER ${MAIN_USER}  
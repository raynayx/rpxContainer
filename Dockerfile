FROM fedora:40

ENV REFRESHED_AT=2025-01-27

# Add timezone info and that we are not interactive
# so that cmake installs without prompts. 
ENV TZ=Africa/Accra

# Download Linux support tools
RUN dnf update -y && \
    dnf clean all


RUN dnf groupinstall -y "Development Tools"

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
        xz


#  JLink dependencies 
RUN dnf install -y libXrandr \
    libXfixes \
    libXcursor \
    ncurses-compat-libs \
    @base-x         


# Set the dev directory
WORKDIR /root/dev


# Download and install RP2040 Toolchains
# RUN curl -o /root/opt/arm-none-eabi-14.tar.xz \
# https://developer.arm.com/-/media/Files/downloads/gnu/14.2.rel1/binrel/arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-eabi.tar.xz

#Copy and install arm-none-eabi-toolchain
COPY arm-none-eabi-14.tar.xz /root/opt/
RUN cd /root/opt/ && \
    tar -xf arm-none-eabi-14.tar.xz &&\
    mv arm-gnu-toolchain-* arm-none-eabi/ &&\
    rm ./arm-none-eabi-* 

ENV PATH=$PATH:/root/opt/arm-none-eabi/bin/


# Clone and setup the RP2040 SDK
RUN git clone https://github.com/raspberrypi/pico-sdk /root/opt/pico-sdk/

RUN cd /root/opt/pico-sdk/ &&\
    git submodule update --init

# get, build and install picotool
RUN git clone https://github.com/raspberrypi/picotool.git /root/opt/picotool
RUN mkdir /root/opt/picotool_bin
RUN cd /root/opt/picotool/ &&\
    mkdir build
RUN cd /root/opt/picotool/build &&\
    cmake -DCMAKE_INSTALL_PREFIX=/root/opt/picotool_bin/ \
    -DPICO_SDK_PATH=/root/opt/pico-sdk -DPICOTOOL_FLAT_INSTALL=1 .. 
    
RUN cd /root/opt/picotool/build &&\
    make install



#Download JLink_V798h.rpm
# RUN curl -o /home/opt/JLink_V798h.rpm --data "accept_license_agreement=accepted" https://www.segger.com/downloads/jlink/JLink_Linux_V798h_x86_64.rpm

COPY JLink_V798h.rpm /root/opt/
RUN cd /root/opt/ &&\
    dnf install -y ./JLink_V798h.rpm &&\
    rm JLink_V*

    
RUN cd /root/dev/
ENV PICO_SDK_PATH=/root/opt/pico-sdk/
ENV CMAKE_CXX_COMPILER=/root/opt/arm-none-eabi/bin/arm-none-eabi-g++

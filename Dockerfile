FROM fedora:40

ENV REFRESHED_AT=2025-01-23

# Add timezone info and that we are not interactive
# so that cmake installs without prompts. 
ENV TZ=Africa/Accra
ENV DEBIAN_FRONTEND=noninteractive

# Download Linux support tools
RUN dnf update -y && \
    dnf clean all

RUN dnf groupinstall -y "Development Tools"

RUN dnf install -y \
        wget \
        git  \
        python3-pip\
        python3-invoke


# Set the dev directory
WORKDIR /root/dev

#install g++ compiler
RUN dnf install -y g++

# Download and install RP2040 Toolchains
RUN dnf install -y cmake \
        arm-none-eabi-gcc-cs \
        arm-none-eabi-gcc-cs-c++


# Clone and setup the RP2040 SDK
RUN git clone https://github.com/raspberrypi/pico-sdk /root/opt/pico-sdk/

RUN cd /root/opt/pico-sdk/ &&\
    git submodule update --init

# get and install picotool
RUN git clone https://github.com/raspberrypi/picotool.git /root/opt/picotool
RUN mkdir /root/opt/picotool_bin
RUN cd /root/opt/picotool/ &&\
    mkdir build
RUN cd /root/opt/picotool/build &&\
    cmake -DCMAKE_INSTALL_PREFIX=/root/opt/picotool_bin/ \
    -DPICO_SDK_PATH=/root/opt/pico-sdk -DPICOTOOL_FLAT_INSTALL=1 .. 
    
RUN cd /root/opt/picotool/build &&\
    make install




#JLink dependencies
# RUN  dnf install -y xcb-util-renderutil 
# RUN  dnf install -y libxcb
# RUN  dnf install -y libxcb-shm
# # RUN  dnf install -y xcb-icccm
# # RUN  dnf install -y xcb-keysyms
# # RUN  dnf install -y xcb-image
# RUN  dnf install -y libxkbcommon
# RUN  dnf install -y libxkbcommon-x11
     
RUN dnf install -y libXrandr 
RUN dnf install -y libXfixes
RUN dnf install -y libXcursor

RUN dnf install -y ncurses-compat-libs
RUN dnf install -y @base-x
# RUN dnf install -y 'dnf-command(builddep)'

#Download JLink_V798h.rpm
# RUN curl -o /home/opt/JLink_V798h.rpm --data "accept_license_agreement=accepted" https://www.segger.com/downloads/jlink/JLink_Linux_V798h_x86_64.rpm

COPY JLink_V798h.rpm /root/opt/
RUN cd /root/opt/ &&\
    dnf install -y ./JLink_V798h.rpm

RUN dnf install -y vim
RUN dnf install -y arm-none-eabi-newlib
RUN dnf install -y ninja-build
    
RUN cd /root/dev/
ENV PICO_SDK_PATH=/root/opt/pico-sdk/

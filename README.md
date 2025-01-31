# Raspberry Pi RP2 Series Container

## Intro
This  makes setting up the development environment for the RP2040 and RP2350 series of MCUs easy.

## How to create the image based on the Dockerfile
- Build the image based on the Dockerfile:
```bash
docker buildx build -t namespace/image_name -f path_to_Dockerfile .
```

## Run a container based on the built image
In order to allow the container to connect with USB devices(like JLink programmer), pass the `--privileged` flag and mount `/dev/bus/usb` in the container.

For example:
```bash
docker run -it --mount type=bind,src=project/directory/,dst=/home/rpx/dev --privileged -v /dev/bus/usb/:/dev/bus/usb namespace/image_name  /bin/bash
```

## Using the container for development
The container uses the [Invoke](https://www.pyinvoke.org/) tool for managing tasks within the project environment.

At the terminal, type `invoke -l` or `inv -l` to see a list of the tasks defined in the `tasks.py` 
defined in your project.

## Build firmware in the container from the terminal
```bash
invoke build
```

## Flash firmware in the container from the terminal
Having connected the JLink Debugger and the powered the MCU board, run:
```bash
invoke flash

```


The Dockerfile is based on the Fedora:40 image.
It creates an image with the following:
- arm-none-eabi compiler toolchain
- pico-sdk
- picotool
- JLink tools 
- Invoke

The resources required are to be downloaded separately into the same directory as the Dockerfile.
Alternatively,you can uncomment the curl commands in the Dockerfile.
These are:
- [`arm-none-eabi-14.tar.xz`](https://developer.arm.com/-/media/Files/downloads/gnu/14.2.rel1/binrel/arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-eabi.tar.xz)
- [`JLink_V812d.rpm`](https://www.segger.com/downloads/jlink/JLink_Linux_V798h_x86_64.rpm)

The arm toolchain and the pico-sdk are in the `/opt` directory in the home directory of the default user `rpx`.
`~/opt/arm-none-eabi/` and `~/opt/pico-sdk`

The default user can be set by passing the build arg
`--build-args MAIN_USER=your_user`.


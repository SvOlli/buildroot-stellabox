# buildroot-stellabox #

## About ##

This is more like a demonstrator on how to create an own buildroot based
project, using the br2-external mechanism.

As an example this projects builds an image that boots directly into the
Atari 2600 VCS emulator [Stella](https://stella-emu.github.io).

The approach is very flat, as the emulator runs as root, but it gets the
job done, and security is not that much of an issue here.

This is more a demonstrator than a finished produced. It is intended to
show the capabilities of buildroot and this setup.sh-script.

## Building ##

Run
```
./setup.sh
```
This will output all possible config files to use. Then you will be told
that the two options you have are
```
./setup.sh stellabox/configs/stellabox_raspberrypi3_defconfig
./setup.sh stellabox/configs/stellabox_raspberrypi4_defconfig
```
Once you're running on the those commands a buildroot tarball will get
downloaded and a build directory will be set up.

After this you can do the following to customize your system using the
following commands:
```
cd output/stellabox_raspberrypi3 # or ...pi4
make menuconfig                  # modify configuration
make help                        # get an overview of useful make targets
make all                         # build the actual image
make source                      # pre-download all required sourcefiles
```

Have fun,
  SvOlli

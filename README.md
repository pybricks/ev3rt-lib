# ev3rt-hrp3
RTOS for Mindstorms EV3 w/ TOPPERS/HRP3 Kernel.

It can be used independently or with [Pybricks](https://github.com/pybricks/pybricks-micropython).

# Prerequisites

```
sudo apt install ruby u-boot-tools gcc-arm-none-eabi
sudo gem install shell
```

Prepare a microSD card (16 GB or less) and format it as a single FAT32 partition.

# Usage



```bash
# Clone.
git clone https://github.com/pybricks/ev3rt-lib.git
cd ev3rt-lib

# Build uImage. This builds the helloev3 example.
make -C sdk/workspace/ img=helloev3

# Copy to root of microSD card, e.g:
cp sdk/workspace/uImage /media/user_name/disk_name/uImage

# Insert microSD card and run!
```

#!/usr/bin/env -S bash



KERNEL_HOME="$LINSTRAP_HOME/kernel"
# https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.12.6.tar.xz

# TODO Check and extract the kernel to the correct directory
# TODO Make universal compatibility, maybe use a custom chroot to build kernel.

apt install build-essential libncurses-dev libelf-dev

#apt -y install git gcc curl make libxml2-utils flex m4
#apt -y install openjdk-8-jdk lib32stdc++6 libelf-dev
#apt -y install libssl-dev python-enum34 python-mako syslinux-utils

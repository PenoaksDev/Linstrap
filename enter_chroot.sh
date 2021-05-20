# This software may be modified and distributed under the terms
# of the MIT license.  See the LICENSE file for details.
#
# Copyright (c) 2021 Amelia Sara Greene <barelyaprincess@gmail.com>
# Copyright (c) 2021 Penoaks Publishing LLC <development@penoaks.com>
#
#!/bin/bash

PWD=`dirname $0`

source "${PWD}/bin/functions"
check_env

CMD=/bin/bash

[ -d "${CHROOT}" ] || ${PWD}/create_chroot.sh

LINSTRAP_SRC="${CHROOT}/usr/src/Linstrap"

cp /etc/hosts ${CHROOT}/etc/hosts
mkdir -p "${LINSTRAP_SRC}"

mount proc ${CHROOT}/proc -t proc
mount sysfs ${CHROOT}/sys -t sysfs
mount --bind ${PWD} "${LINSTRAP_SRC}"

echo "All is good, now entering the chroot environment."
echo ""

chroot "${CHROOT}" "${CMD}"

umount "${LINSTRAP_SRC}"
umount ${CHROOT}/proc
umount ${CHROOT}/sys
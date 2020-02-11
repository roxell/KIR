#!/bin/bash
# SPDX-License-Identifier: MIT

set -e
#set -xe

. $(dirname $0)/libhelper

if [[ -d /lava-lxc ]]; then
	cd /lava-lxc
else
	mkdir -p $(pwd)/lava-lxc
	cd $(pwd)/lava-lxc
fi


new_size="1M"
new_file_name=x15_u-boot.img

usage() {
	echo -e "$0's help text"
	echo -e "   -m MLO_URL, specify a url to a device tree blob file."
	echo -e "      Can be to a file on disk: file:///path/to/MLO"
	echo -e "   -u UBOOT_URL, specify a url to a u-boot.img."
	echo -e "      Can be to a file on disk: file:///path/to/file.img"
	echo -e "   -h, prints out this help"
}

while getopts "m:u:h" arg; do
	case $arg in
	m)
		LXC_MLO_URL="$OPTARG"
		;;
	u)
		LXC_UBOOT_URL="$OPTARG"
		;;
	h|*)
		usage
		exit 0
		;;
	esac
done

LXC_MLO_FILE=$(curl_me "${LXC_MLO_URL}")
LXC_UBOOT_FILE=$(curl_me "${LXC_UBOOT_URL}")

get_and_create_a_ddfile "${new_file_name}" "${new_size}" "48" "0" "fat -F 16"

mount_point_dir=$(get_mountpoint_dir)

cp "${LXC_MLO_FILE}" "${mount_point_dir}"/
cp "${LXC_UBOOT_FILE}" "${mount_point_dir}"/
virt_copy_in ${new_file_name} ${mount_point_dir}

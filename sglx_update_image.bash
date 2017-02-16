#!/bin/bash
#(C) Copyright 2016 Hewlett Packard Enterprise Development Company, L.P.

#
# This script copies the contents of SG ISO and 
# builds a new ISO containing latest cmeasyinstall script
# shipped with the heat bundle/tar file for SG.
#
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/lbin:$PATH
export PATH=$PATH

#
# Usage
#
function usage
{
    echo "Usage:"
    echo "sglx_update_image.bash <path_of_the_Serviceguard_ISO>"
}

#
# Cleanup
#
function cleanup
{
    # Remove the temp folders
    umount /tmp/sgiso_mnt > /dev/null 2>&1
    rm -rf /tmp/sgiso_mnt > /dev/null 2>&1
    rm -rf /tmp/sgiso_dir > /dev/null 2>&1

}

#
# The script requires 1 input
# Location - Full file name path of the SG ISO
# Quit if the input is not provided.
#
orig_iso_file_loc=$1

if [[ -z "$orig_iso_file_loc" ]]; then
    echo "Provide the Full file name path of the Serviceguard ISO file"
    usage
    exit 1
elif [[ ! -e $orig_iso_file_loc ]]; then
    echo "ERROR: The file $orig_iso_file_loc does not exist"
    echo "Provide the correct location of the Serviceguard ISO file"
    exit 1
fi

# This script requires that mkisofs must be available on this node.
# If not just exit.
mkisofs -version > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "ERROR: mkisofs is not available on this system."
    echo "Install the binary mkisofs before running the script again."
    exit 1
fi

# create the required temporary directories
#   /tmp/sgiso_dir - to copy contents
#   /tmp/sgiso_mnt - to mount the iso
cleanup
mkdir -p /tmp/sgiso_dir > /dev/null 2>&1
mkdir -p /tmp/sgiso_mnt > /dev/null 2>&1

# Copy the iso contents to temporary location
mount -o loop $orig_iso_file_loc /tmp/sgiso_mnt > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "ERROR: Failed to mount $orig_iso_file_loc"
    exit 1
fi

cp -R /tmp/sgiso_mnt/* /tmp/sgiso_dir

# Copy the cmeasyinstall file
# Ensure that we do cp -f or remove old cmeasyinstall and replace with new one.
# Check the Permissions of cmeasyinstall in old CD and ensure that the new cmeasyinstall also contains the same permissions.
rm -f /tmp/sgiso_dir/cmeasyinstall > /dev/null 2>&1
cp -f `pwd`/cmeasyinstall /tmp/sgiso_dir/cmeasyinstall > /dev/null 2>&1
chmod +x /tmp/sgiso_dir/cmeasyinstall 

new_iso_file="sglx"
new_iso_file_loc=`pwd`/"$new_iso_file".iso

# Build the iso file
mkisofs -joliet-long -l -R -V $new_iso_file -o $new_iso_file_loc -log-file iso_msg.log  /tmp/sgiso_dir > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "ERROR: Failed to create the iso file"
    echo "please look at iso_msg.log file"
    cleanup
    exit 1
fi

echo "Successfully created the iso file $new_iso_file_loc."
cleanup
exit 0

#!/bin/bash
# Helpful to read output when debugging
set -x

echo "Beginning startup!"

# Load the config file with our environmental variables
source "/etc/libvirt/hooks/kvm.conf"

# Stop display manager
systemctl stop display-manager.service
## Uncomment the following line if you use GDM
killall gdm-x-session

## Unbind VTconsoles
echo 0 > /sys/class/vtconsole/vtcon0/bind
## Some machines might have more than 1 virtual console. Add a line for each corresponding VTConsole
#echo 0 > /sys/class/vtconsole/vtcon1/bind

## Unbind EFI-Framebuffer
echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

# Avoid a race condition by waiting a couple of seconds. This can be calibrated to be shorter or longer if required for your system
sleep 5

# Unload all Nvidia drivers
modprobe -r nvidia_drm
modprobe -r nvidia_modeset
modprobe -r nvidia_uvm
modprobe -r nvidia

# Unbind the GPU from display driver
virsh nodedev-detach $VIRSH_GPU_VIDEO
virsh nodedev-detach $VIRSH_GPU_AUDIO

# Load VFIO kernel module
modprobe vfio
modprobe vfio_pci
modprobe vfio_iommu_type1

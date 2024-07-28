#!/usr/bin/env bash
set -euo pipefail

# Export all variables
set -a
# Call the systemd generator that reads all files in environment.d
source /dev/fd/0 <<EOF
$(/usr/lib/systemd/user-environment-generators/30-systemd-environment-d-generator)
EOF
set +a

# Play with wireplumber, only on Sway
DIR=/home/devansh/.config/wireplumber/wireplumber.conf.d
FILE=$DIR/51-disable-webcam-mic.conf

rm -f $FILE
mkdir -p $DIR
echo "
monitor.alsa.rules = [
  {
    matches = [
      {
        device.name = \"v4l2_device.pci-0000_00_14.0-usb-0_3_1.0\"
      }
    ]
    actions = {
      update-props = {
         device.disabled = true
      }
    }
  },
  {
    matches = [
      {
        device.name = \"libcamera_device.\_SB_.PC00.XHCI.RHUB.HS03-3:1.0-30c9:0013\"
      }
    ]
    actions = {
      update-props = {
         device.disabled = true
      }
    }
  },
  {
    matches = [
      {
        node.name = \"alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic1__source\"
      }
    ]
    actions = {
      update-props = {
         node.disabled = true
      }
    }
  }
]
" >>$FILE

unset FILE
unset DIR

exec sway

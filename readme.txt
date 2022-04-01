Prerequistes:

0) Start with a system running moode (image moode-r730-iso.zip tested), attached to a television with an HDMI cable.

1) Enable the local UI display for moode in Settings > System > Local Display > Local UI Display

2) Connect your pi to a network with internet access

At this point, you should see your Moode UI on your televsion. 

Script Installation:

# Install cec-utils
sudo apt-get install cec-utils
# Install the script
cd /opt
sudo mkdir shoefone
sudo mkdir shoefone/cec
cd shoefone/cec
sudo pico moode_cec_mon_v1.0.sh
: copypaste the .sh script into your txtfile
: C-o to write
: C-x to exit
# Install the service
cd /etc/systemd/system
sudo pico moode_cec_mon.service
: copypaste the .service file into your txtfile
: C-o to write
: C-x to exit
# Start the service
sudo systemctl enable moode_cec_mon.service
# Reboot
sudo shutdown -r now
# Test the service
: Start playing an album
: Test the play / pause / stop / prev / next / rwd / ffwd buttons

General Notes:

moode_cec_mon.service < Defines the systemd service
moode_cec_mon_v1.0.sh < The script that will run to capture CEC signals

For the script to function, 
- The TV and moode device must both be powered on and connected over HDMI
- The moode device must either be playing music or be in a paused state

If the above is true, then the following buttons on your remote control
should now control the moode player:
Play, Pause, Stop, Back, Forward, Rewind, Fast Forward

NB that the signals from the remote control go through the TV; point it at 
the TV as normal when trying this!

Note that there are a large number of CEC godes still untapped, many of which
could be useful for moode. To test what buttons on your remote control cause
the TV to emit a CEC signal, run the following command from the terminal:
cec-client

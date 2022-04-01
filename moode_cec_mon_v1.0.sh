# cec_mon_script_v2.0.sh
# Monitors CEC transmissions from TVs to control play/pause/ffwd/etc functions in moode audio. Does not control UI navigation (yet!)
# This has been tested by running it standalone, as well as as a service, according to https://www.wikihow.com/Execute-a-Script-at-Startup-on-the-Raspberry-Pi

# This script started from the example posted at
# https://ownyourbits.com/2017/02/02/control-your-raspberry-pi-with-your-tv-remote/
# The basic structure and a few lines of code from that are in this script
# Original copyright:
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!

# This is based in part on information from the CEC spec, found at
# https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/xtreamerdev/CEC_Specs.pdf

# The basic method is to read the log output from cec-client, line by line
# Traffic messages from the log output are parsed to see if they correspond to a known button event
# If they do, a call to music player daemon (mpc) is made, which corresponds to the desired user action
# To do this, a filter_key() function is defined which decides if there is a match between the known button event descriptor and the log message
# The log output is monitored in an infinite loop; any matches to filter_key() cause a mpc call to be made

# This regex is simple but tricky (to me at least!)
# It looks for lines beginning with 'TRAFFIC', which is a message->level string in cec-client (found in the CecLogMessage function)
# It then compares the last chars of the message against the chars of the message descriptor and control code sent to it (the $2 variable)
# The message descriptor and control code sent to it will match one of the items in the list of control codes manually defined below
# The TRAFFIC log items from cec-client define three things.
# UNKNOWN:MESSAGE_DESCRIPTOR:USER_CONTROL_CODE
# The first is unknown (always 02 on the tested system)
# The second defines, among other things, the button state (always 44 or 8B on the tested system), defined in table 13 of the spec
# The third defines the user action, defined in table 27 of the spec

filter_key(){ grep -q "TRAFFIC.*$1" <( echo "$2" ) ; }

# SCANJUMP defines how many seconds to jump when the rewind/ffwd buttons are pressed
# Format is HH:MM:SS
SCANJUMP="00:00:05"

# These are the Message Descriptor values based on the CEC spec
# Only one is included; it indicates that the button has been released
# Many others are defined in the spec (CEC Spec v1.3a, table 13)
Button_Up="8B"

# These are named User Control Code values based on the CEC spec
# Only a few of these are used in this version of the script (2.0)
# The others are either not available as control codes on the TV used for testing,
# or are available but have not been implemented (eg the up/down/left/right/select)
# TODO: implement moode audio UI navigation using these control codes

Select="00"
Up="01"
Down="02"
Left="03"
Right="04"
Right_Up="05"
Right_Down="06"
Left_Up="07"
Left_Down="08"
Root_Menu="09"
Setup_Menu="0A"
Contents_Menu="0B"
Favorite_Menu="0C"
Exit="0D"
Num_0="20"
Num_1="21"
Num_2="22"
Num_3="23"
Num_4="24"
Num_5="25"
Num_6="26"
Num_7="27"
Num_8="28"
Num_9="29"
Dot="2A"
Enter="2B"
Clear="2C"
Next_Favorite="2F"
Channel_Up="30"
Channel_Down="31"
Previous_Channel="32"
Sound_Select="33"
Input_Select="34"
Display_Information="35"
Help="36"
Page_Up="37"
Page_Down="38"
Power="40"
Volume_Up="41"
Volume_Down="42"
Mute="43"
Play="44"
Stop="45"
Pause="46"
Record="47"
Rewind="48"
Fast_forward="49"
Eject="4A"
Forward="4B"
Backward="4C"
Stop_Record="4D"
Pause_Record="4E"
Angle="50"
Sub_picture="51"
Video_on_Demand="52"
Electronic_Program_Guide="53"
Timer_Programming="54"
Initial_Configuration="55"
Play_Function="60"
Pause_Play_Function="61"
Record_Function="62"
Pause_Record_Function="63"
Stop_Function="64"
Mute_Function="65"
Restore_Volume_Function="66"
Tune_Function="67"
Select_Media_Function="68"
Select_AV_Input_Function="69"
Select_Audio_Input_Function="6A"
Power_Toggle_Function="6B"
Power_Off_Function="6C"
Power_On_Function="6D"
F1_Blue="71"
F2_Red="72"
F3_Green="73"
F4_Yellow="74"
F5="75"
Data="76"

while :; do
  # Try to capture Ctrl-C, in case the script is run directly
  trap break SIGINT
  cec-client | while read cec_line; do
    # Convert string to uppercase to avoid any system-specific differences
    # in how hex codes are represented (lowercase in tested system)
    cec_line=${cec_line^^}
    # Try to capture Ctrl-C, in case the script is run directly
    trap break SIGINT
    # The meat of the program: match output from cec-client against a known pattern, and issue a mpc command based on that
    if  filter_key "${Button_Up}\:${Pause}" "$cec_line"; then
      mpc pause
    fi
    if  filter_key "${Button_Up}\:${Play}" "$cec_line"; then
      mpc play
    fi
    if  filter_key "${Button_Up}\:${Stop}" "$cec_line"; then
      mpc stop
    fi
    if  filter_key "${Button_Up}\:${Backward}" "$cec_line"; then
      mpc prev
    fi
    if  filter_key "${Button_Up}\:${Rewind}" "$cec_line"; then
      mpc seekthrough -$SCANJUMP
    fi
    if  filter_key "${Button_Up}\:${Fast_forward}" "$cec_line"; then
      mpc seekthrough +$SCANJUMP
    fi
    if  filter_key "${Button_Up}\:${Forward}" "$cec_line"; then
      mpc next
    fi
  done
done

# License
#
# This script is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this script; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place, Suite 330,
# Boston, MA  02111-1307  USA

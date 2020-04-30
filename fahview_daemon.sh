#!/bin/bash
# Data collecting Process for fahmon.sh
# Dependencies: nvidia-smi, lm-sensors, curl, jq

#################### Temperature ####################
# Getting CPU Temperature from 'lm-sensors'
# Getting GPU Temperature and Power Draw from 'nvidia-smi'
# TO-DO: Parse data with something other than 'cut' to always get the acurate data

# cpu_temp=`sensors | grep "Tdie" | cut -c16-19`
# t1050=`nvidia-smi | grep "P0" | grep -o "[1-9][0-9]C"`
# t1080=`nvidia-smi | grep "P2" | grep -o "[1-9][0-9]C"`
# p1050=`nvidia-smi | grep "P0" | cut -c22-24`
# p1080=`nvidia-smi | grep "P2" | cut -c21-31`



echo  "+------------------------------------------+"
echo  "|     Dev     |     Temp     |    Power    |"
echo  "|=============|==============|=============|"
echo  "|     CPU     |    $cpu_temp°C    |     N/A     |"
echo  "|-------------|--------------|-------------|"
echo  "| GTX 1050 Ti |     $t1050°C     |     $p1050     |"
echo  "|-------------|--------------|-------------|"
echo  "| GTX 1080 Ti |     $t1080°C     | $p1080 |"
echo  "+------------------------------------------+"
echo
echo


#################### Folding Identity ####################
# TO-DO: Make donor_name dynamic
donor_name="colsonxu"
data="/tmp/fahview.tmp"
# Getting data using Folding@home Web API
# Stroing gathered data in /tmp
# Potential issue with frequent API request <CAUTION!>
curl -so $data "https://stats.foldingathome.org/api/donor/$donor_name"

# Processing raw data
global_rank="`jq .rank $data` / `jq .total_users $data`"
total_credits=`jq .credit $data`
current_team=`jq '.teams[-1] | .name' $data`
credits_towards_current_team=`jq '.teams[-1] | .credit' $data`

# Displaying processed data
echo "Donor Name: $donor_name"
echo "Total Credits: $total_credits"
echo "Global Rank: $global_rank"
echo "Current Team: $current_team"
echo "Credits Towards Current Team: $credits_towards_current_team"
echo


#################### Folding Progress ####################
# Getting FAHClient Folding Progress from Log File
FS0=`cat /var/lib/fahclient/log.txt | grep "FS00" | grep -Po "[1-9][0-9]?%|100%" | tail -n 1 | grep -Po "[1-9][0-9]?|100"`
FS1=`cat /var/lib/fahclient/log.txt | grep "FS01" | grep -Po "[1-9][0-9]?%|100%" | tail -n 1 | grep -Po "[1-9][0-9]?|100"`
FS2=`cat /var/lib/fahclient/log.txt | grep "FS02" | grep -Po "[1-9][0-9]?%|100%" | tail -n 1 | grep -Po "[1-9][0-9]?|100"`


prog() {
	local w=50 p=$1;	shift
	# Assigning Device Names
	if [ $p == $FS0 ]
	then
		FS="Ryzen 5 1600"
	elif [ $p == $FS1 ]
	then
		FS=" GTX 1050 Ti"
	elif [ $p == $FS2 ]
	then
		FS=" GTX 1080 Ti"
	fi
	# Displaying Progress Bar
	printf -v bars "%*s" "$(( $p*$w/100 ))" ""; bars=${bars// /=};
	printf "$FS [%-*s]%3d%% %s \n" "$w" "$bars" "$p" "$*";
}


prog $FS0
prog $FS1
prog $FS2


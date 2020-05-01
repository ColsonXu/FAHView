#!/bin/bash
# Data collecting Process for fahmon.sh
# Dependencies: nvidia-smi, lm-sensors, curl, jq

#################### Temperature ####################
# Getting CPU Temperature from 'lm-sensors'
# Getting GPU Temperature and Power Draw from 'nvidia-smi'

total_gpus=`nvidia-smi --query-gpu=count --format=csv | tail -1`

# Loop though each GPUs and assign values
for ((i=0; i<$total_gpus; i++)); do
	# Assign name
	declare "gpu_name_$i"="`nvidia-smi -i $i --query-gpu=name --format=csv | tail -1`"
	# Assign GPU temp
	declare "gpu_temp_$i"="`nvidia-smi -i $i --query-gpu=temperature.gpu --format=csv | tail -1`"
	# Assign memory temp
	declare "gpu_mem_temp_$i"="`nvidia-smi -i $i --query-gpu=temperature.memory --format=csv | tail -1`"
	# Assign fan speed
	declare "gpu_fan_$i"="`nvidia-smi -i $i --query-gpu=fan.speed --format=csv | tail -1`"
	# Assign power draw
	declare "gpu_power_$i"="`nvidia-smi -i $i --query-gpu=power.draw --format=csv | tail -1`"
done

# Loop through all GPU variables and display information
for ((i=0; i<$total_gpus; i++)); do
	# GPU name
	gpu_name="gpu_name_$i"
	echo "${!gpu_name}"

	# Core temp
	gpu_temp="gpu_temp_$i"
	echo "Core Temp: ${!gpu_temp}°C"

	# VRAM temp
	gpu_mem_temp="gpu_mem_temp_$i"
	echo "VRAM Temp: ${!gpu_mem_temp}"

	# GPU fan (percentage)
	gpu_fan="gpu_fan_$i"
	echo "GPU Fan Speed: ${!gpu_fan}"

	# GPU power draw
	gpu_power="gpu_power_$i"
	echo "GPU Power Draw: ${!gpu_power}"
	echo
done


# echo  "+------------------------------------------+"
# echo  "|     Dev     |     Temp     |    Power    |"
# echo  "|=============|==============|=============|"
# echo  "|     CPU     |    $cpu_temp°C    |     N/A     |"
# echo  "|-------------|--------------|-------------|"
# echo  "| GTX 1050 Ti |     $t1050°C     |     $p1050     |"
# echo  "|-------------|--------------|-------------|"
# echo  "| GTX 1080 Ti |     $t1080°C     | $p1080 |"
# echo  "+------------------------------------------+"
echo
echo


#################### Folding Identity ####################
donor_name=`cat /var/lib/fahclient/log.txt | grep "user v="| grep -Po "'(?s)(.*)'" | tail -1`
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
cause=`cat /var/lib/fahclient/log.txt | grep "cause v="| grep -Po "'(?s)(.*)'" | tail -1`

# Displaying processed data
echo "Donor Name: $donor_name"
echo "I am folding to cure $cause"
echo "Total Credits: $total_credits"
echo "Global Rank: $global_rank"
echo "Current Team: $current_team"
echo "Credits Towards Current Team: $credits_towards_current_team"
echo


#################### Folding Progress ####################
# Getting FAHClient Folding Progress from Log File
FS0=`cat /var/lib/fahclient/log.txt | grep "FS00" | grep -Po "[0-9][0-9]?%|100%" | tail -1 | grep -Po "[1-9][0-9]?|100"`
FS1=`cat /var/lib/fahclient/log.txt | grep "FS01" | grep -Po "[0-9][0-9]?%|100%" | tail -1 | grep -Po "[1-9][0-9]?|100"`
FS2=`cat /var/lib/fahclient/log.txt | grep "FS02" | grep -Po "[0-9][0-9]?%|100%" | tail -1 | grep -Po "[1-9][0-9]?|100"`

# TO-DO: Progress bar error when current progress is 0%
prog() {
	local w=50 p=$1;	shift
	# Assigning Device Names
	if [ $p == $FS0 ]; then
		FS="Ryzen 5 1600"
	elif [ $p == $FS1 ]; then
		FS=" GTX 1050 Ti"
	elif [ $p == $FS2 ]; then
		FS=" GTX 1080 Ti"
	fi
	# Displaying Progress Bar
	printf -v bars "%*s" "$(( $p*$w/100 ))" ""; bars=${bars// /=};
	printf "$FS [%-*s]%3d%% %s \n" "$w" "$bars" "$p" "$*";
}


prog $FS0
prog $FS1
prog $FS2

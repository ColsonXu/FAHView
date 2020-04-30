#!/bin/bash
# Data collecting Process for fahmon.sh

# Getting CPU Temperature from 'lm-sensor'
# Getting GPU Temperature and Power Draw from 'nvidia-smi'
cpu_temp=`sensors | grep "Tdie" | cut -c16-19`
t1050=`nvidia-smi | grep "P0" | cut -c9-10`
t1080=`nvidia-smi | grep "P2" | cut -c9-10`
p1050=`nvidia-smi | grep "P0" | cut -c22-24`
p1080=`nvidia-smi | grep "P2" | cut -c21-31`


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

# Getting FAHClient Folding Progress from Log File
FS0=`cat /var/lib/fahclient/log.txt | grep "FS00" | grep -Po "[1-9][0-9]?%|100%" | tail -n 1`
FS1=`cat /var/lib/fahclient/log.txt | grep "FS01" | grep -Po "[1-9][0-9]?%|100%" | tail -n 1`
FS2=`cat /var/lib/fahclient/log.txt | grep "FS02" | grep -Po "[1-9][0-9]?%|100%" | tail -n 1`

# Remove "%" to Get Integer Value
trim() {
	FS=$1
	if [ ${#FS} == 2 ]
	then
		echo $FS | cut -c1-1
	elif [ ${#FS} == 3 ]
	then
		echo $FS | cut -c1-2
	elif [ ${#FS} == 4 ]
	then
		echo $FS | cut -c1-3
	fi
}

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
	printf -v bars "%*s" "$(( $p*$w/100 ))" ""; bars=${bars// /#};
	printf "$FS [%-*s]%3d%% %s \n" "$w" "$bars" "$p" "$*";
}


FS0=$(trim $FS0)
FS1=$(trim $FS1)
FS2=$(trim $FS2)
prog $FS0
prog $FS1
prog $FS2


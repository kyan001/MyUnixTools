#!/bin/bash
#
#=================================================================
# ClearAndPwd.sh
#   Clear your terminal screen, show your current location.
#
# HISTORY
#-----------------------------------------------------------------
#     DATE    |     AUTHOR     |  VERSION | COMMENT
#-------------+----------------+----------+-----------------------
#  2013-03-07 |     YAN Kai    |   V1.0   | Script Creation
#             |                |          |                
#-----------------------------------------------------------------
#=================================================================
#

#--Variables Defination-------------------------------------------
# Normal Bold Underline Gray Red Purple BLUE
VN="\e[0m";VB="\e[1m";VU="\e[4m";VG="\e[2m";VR="\e[31m";VP="\e[35m";VBLUE="\e[34m";

#--Common Variables-----------------------------------------------
v_pwd=`pwd`;
v_dirname=`dirname ${v_pwd}`;
v_dirname_2nd=`dirname ${v_dirname}`;
v_basename=`basename ${v_pwd}`;
v_basename_2nd=`basename ${v_dirname}`;

#--Flags----------------------------------------------------------
clear_flag=1;
color_flag=1;
list_flag=1;

#--Param Processing-----------------------------------------------
until [ $# = 0 ]
do
	case "$1" in
	-noclear)
		clear_flag=0;
		shift
		;;
	-nocolor)
		color_flag=0;
		shift
		;;
	-nolist)
		list_flag=0;
		shift
		;;
	*)
		echo -e "${VR}${VB}[ERR] Wrong parameter: $1${VN}";
		shift
		;;
	esac
done

#--Main-----------------------------------------------------------
if [ ${clear_flag} = 1 ]
then	clear;
fi

echo "";
echo -e "${VB}--------------------------------------------------------${VN}";
if [ ${color_flag} = 1 ]
then	echo -e "${v_dirname_2nd}/${VBLUE}${v_basename_2nd}${VN}/${VR}${v_basename}${VN}";
else	echo -e "${v_dirname_2nd}/${VB}${v_basename_2nd}${VN}/${VB}${v_basename}${VN}";
fi
echo -e "${VB}--------------------------------------------------------${VN}";

if [ ${list_flag} = 1 ]
then	
	echo "";
	ls;
	echo "";
	echo -e "${VB}--------------------------------------------------------${VN}";
fi

echo "";

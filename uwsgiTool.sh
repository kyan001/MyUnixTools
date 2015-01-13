#!/bin/bash
#
#=================================================================
# uwsgiTool.sh
#
# HISTORY
#-----------------------------------------------------------------
#     DATE    |     AUTHOR     |  VERSION | COMMENT
#-------------+----------------+----------+-----------------------
#  2015-01-13 |     YAN Kai    |   V1.0   | Script Creation
#             |                |          |
#-----------------------------------------------------------------
#=================================================================
#

#--Variables Defination-------------------------------------------
# Normal Bold Underline Gray Red Purple BLUE
VN="\e[0m";VB="\e[1m";VU="\e[4m";VG="\e[2m";VR="\e[31m";VP="\e[35m";VBLUE="\e[34m";
# KTK
KyanToolKit_Unix_Folder="/home/kyan001/KyanToolKit_Unix"
uwsgi_xml="/var/www/portal/uwsgi.xml"

#--Common Macros--------------------------------------------------
Bold(){ echo -e "${VB}$1${VN}"; }
pWarn(){ echo -e "${VB}${VU}[WARNING]${VN}${VU}$1${VN}"; }
pErr(){ echo -e "${VB}${VR}[ERROR] $1${VN}" 1>&2; }
pInfo(){ echo -e "${VB}${VU}[INFO]${VN} $1"; }
pInfoGray(){ echo -e "${VB}${VG}${VU}[INFO]${VN} ${VG}$1${VN}"; }
Usage(){
	echo ""
	Bold "Usage:"
	echo -e "\t$0"
	echo ""
	echo "1. Please check the Shell content."
	echo ""
	exit 0
}
CheckResult(){
	if [ $? -eq 0 ]
	then	Bold "Done"
	else	Bold "Failed"
	fi
}
RunCmd(){
	pInfo "=========================="
	pInfo "[ $1 ]"
	pInfo "=========================="
	$1
	CheckResult
}

#--Flags----------------------------------------------------------
start_flag=0;
stop_flag=0;
reload_flag=0;

#--Param Processing-----------------------------------------------
if [ $# = 1 ]
then
	case "$1" in
		-start)
			start_flag=1;
			;;
		-stop)
			stop_flag=1;
			;;
		-reload)
			reload_flag=1;
			;;
		*)
			echo -e "${VR}${VB}[ERR] Wrong parameter: $1${VN}";
			;;
	esac
else
	pErr "Please Enter -start / -stop / -reload";
fi

#--Main-----------------------------------------------------------
sudo echo ""
if [ ${start_flag} = 1 ]
then	sudo uwsgi -x '${uwsgi_xml}' --pidfile '/tmp/uwsgi.pid' &;
fi

if [ ${stop_flag} = 1 ]
then	RunCmd "sudo uwsgi --stop /tmp/uwsgi.pid";
fi

if [ ${reload_flag} = 1 ]
then	RunCmd "sudo uwsgi --reload /tmp/uwsgi.pid";
fi

#!/bin/bash
#
#=================================================================
# AutoCreateUser.sh
#   Install necessary softwares on Ubuntu Linux by using apt-get install command.
#   The list of softwares/libs
#
# HISTORY
#-----------------------------------------------------------------
#     DATE    |     AUTHOR     |  VERSION | COMMENT
#-------------+----------------+----------+-----------------------
#  2013-11-02 |     YAN Kai    |   V1.0   | Script Creation
#             |                |          |
#-----------------------------------------------------------------
#=================================================================
#

#--Variables Defination-------------------------------------------
# Normal Bold Underline Gray Red Purple BLUE
VN="\e[0m";VB="\e[1m";VU="\e[4m";VG="\e[2m";VR="\e[31m";VP="\e[35m";VBLUE="\e[34m";
# KTK
KyanToolKit_Unix_Folder="/home/kyan001/KyanToolKit_Unix"
# Install Progress
ALLTASK=8
NOWTASK=1

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
AptGetInstall(){
	pInfo "=========================="
	pInfo "(${NOWTASK}/${ALLTASK}) Installing $1."
	pInfo "=========================="
	sudo apt-get install $1
	CheckResult
	NOWTASK=`expr ${NOWTASK} + 1`
}
RunCmd(){
	pInfo "=========================="
	pInfo "[ $1 ]"
	pInfo "=========================="
	$1
	CheckResult
}

#--Main-----------------------------------------------------------
sudo echo ""
AptGetInstall "tcsh"
AptGetInstall "vnc4server"
AptGetInstall "vim-gtk"
AptGetInstall "kde-workspace-bin"
AptGetInstall "konsole"
AptGetInstall "python3"
AptGetInstall "python3-pip"
AptGetInstall "vim"
AptGetInstall "pptpd"
AptGetInstall "iptables"
# RunCmd "sudo apt-get update"
# RunCmd "sudo apt-get upgrade"

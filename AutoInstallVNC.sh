#!/usr/bin／env bash
#
#=================================================================
# AutoInstallVNC.sh
#   Install vnc4server automatically.
#
# HISTORY
#-----------------------------------------------------------------
#     DATE    |     AUTHOR     |  VERSION | COMMENT
#-------------+----------------+----------+-----------------------
#  2013-11-01 |     YAN Kai    |   V1.0   | Script Creation
#  2013-11-03 |     YAN Kai    |   V1.1   | Functional Available
#             |                |          |
#-----------------------------------------------------------------
#=================================================================
#

#--Variables Defination-------------------------------------------
# Normal Bold Underline Gray Red Purple BLUE
VN="\e[0m";VB="\e[1m";VU="\e[4m";VG="\e[2m";VR="\e[31m";VP="\e[35m";VBLUE="\e[34m";
# KTK
KyanToolKit_Unix_Folder="/home/kyan001/KyanToolKit_Unix"

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
	echo -e "\t$0 -help"
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
	pInfo "[ $1 ] \t... \c"
	$1
	CheckResult
}

#--Preconditions--------------------------------------------------
v_current_user=`whoami`
if [ ${v_current_user} = "root" ]
	then	pErr "This shell must not be done in ROOT user!"
	exit 1
fi

#--Flags----------------------------------------------------------


#--Variables------------------------------------------------------
until [ $# = 0 ]
do
	case "$1" in
	-help)
		Usage;
		shift
		;;
	*)
		pErr "Wrong parameter: $1";
		shift
		exit 1
		;;
	esac
done

#--Main-----------------------------------------------------------
sudo echo ""
# RunCmd "sudo apt-get install vnc4server"
pInfo "[ Set vnc passwd: ]"
vncpasswd
pInfo "[ Writing xstart ]"
RunCmd "touch /home/${v_current_user}/.vnc/xstartup"
RunCmd "chmod 755 /home/${v_current_user}/.vnc/xstartup"
echo "#!/bin/sh" > /home/${v_current_user}/.vnc/xstartup
echo "# Uncomment the following two lines for normal desktop:" >> /home/${v_current_user}/.vnc/xstartup
echo "# unset SESSION_MANAGER" >> /home/${v_current_user}/.vnc/xstartup
echo "# exec /etc/X11/xinit/xinitrc" >> /home/${v_current_user}/.vnc/xstartup
echo "" >> /home/${v_current_user}/.vnc/xstartup
echo "[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup" >> /home/${v_current_user}/.vnc/xstartup
echo "[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources" >> /home/${v_current_user}/.vnc/xstartup
echo "xsetroot -solid grey" >> /home/${v_current_user}/.vnc/xstartup
echo "vncconfig -iconic &" >> /home/${v_current_user}/.vnc/xstartup
echo "x-terminal-emulator -geometry 80x24+10+10 -ls -title \"$VNCDESKTOP Desktop (xterm)\" &" >> /home/${v_current_user}/.vnc/xstartup
echo "x-window-manager &" >> /home/${v_current_user}/.vnc/xstartup
echo "startkde &" >> /home/${v_current_user}/.vnc/xstartup
RunCmd "sudo chmod 775 /etc/X11/xinit/xinitrc"
Bold "\n=========================="
pInfo "Install finished"
pInfo "Please using 'startvnc :1' to start a vnc"
pInfo "Please using 'stopvnc :1' to stop a vnc"
Bold "==========================\n"

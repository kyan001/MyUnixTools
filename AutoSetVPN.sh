#!/bin/bash
#
#=================================================================
# AutoSetVPN.sh
#   Automatically set VPN configs. Use -refresh to refresh VPN connection
#	
# HISTORY
#-----------------------------------------------------------------
#     DATE    |     AUTHOR     |  VERSION | COMMENT
#-------------+----------------+----------+-----------------------
#  2013-11-03 |     YAN Kai    |   V1.0   | Script Creation
#             |                |          |                
#-----------------------------------------------------------------
#=================================================================
#

#--Variables Defination-------------------------------------------
# Normal Bold Underline Gray Red Purple BLUE
VN="\e[0m";VB="\e[1m";VU="\e[4m";VG="\e[2m";VR="\e[31m";VP="\e[35m";VBLUE="\e[34m";
# KTK
KyanToolKit_Unix_Folder="/home/kyan001/KyanToolKit_Unix"
# Parameters
local_ip="173.230.148.199"
remote_ip="10.100.0.2-20"
ms_dns_1="74.207.242.5"
ms_dns_2="8.8.8.8"
iptables_s="10.100.0.0/20"
iptables_o="eth0"

#--Common Macros--------------------------------------------------
Bold(){ echo -e "${VB}$1${VN}"; }
pWarn(){ echo -e "${VB}${VU}[WARNING]${VN}${VU}$1${VN}"; }
pErr(){ echo -e "${VB}${VR}[ERROR] $1${VN}" 1>&2; }
pInfo(){ echo -e "${VB}${VU}[INFO]${VN} $1"; }
pInfoGray(){ echo -e "${VB}${VG}${VU}[INFO]${VN} ${VG}$1${VN}"; }
Usage(){
	echo ""
	Bold "Usage:"
	echo -e "\t$0 -u <username> -p <password>"
	echo -e "\t$0 -ref/resh"
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
vpnRefresh(){
	#pInfo "[ restart networking ]";/etc/init.d/networking restart
	pInfo "[ restart pptpd ]";/etc/init.d/pptpd restart
	pInfo "[ restart ip forward ]";sysctl -p
}

#--Preconditions--------------------------------------------------
if [ $# = 0 ]
then
	pErr "No parameters detected."
	Usage
	exit 1
fi

if [ `whoami` != "root" ]
	then	pErr "This shell must be done in ROOT user!"
	exit 1
fi

until [ $# = 0 ]
do
	case "$1" in
	-help)
		Usage;
		shift
		;;
	-u | -user)
		shift
		v_username="$1";
		shift
		;;
	-p)
		shift
		v_password="$1";
		shift
		;;
	-ref | -refresh)
		vpnRefresh;
		shift
		;;
	*)
		pErr "Wrong parameter: $1";
		shift
		;;
	esac
done

#--Main-----------------------------------------------------------
sudo echo ""

# /etc/pptpd.conf
pInfo "[ Config /etc/pptpd.conf ] \t... \c"
grep "localip" /etc/pptpd.conf | grep -v "#" > /dev/null
if [ $? -eq 0 ]
then
	echo -e "(No Change) \c"
else
	echo "localip $local_ip" >> /etc/pptpd.conf
	echo "remoteip $remote_ip" >> /etc/pptpd.conf	
fi
CheckResult

# /etc/ppp/pptpd-options
pInfo "[ Config /etc/ppp/pptpd-options ] \t... \c"
grep "ms-dns" /etc/ppp/pptpd-options | grep "$ms_dns_1" > /dev/null
if [ $? -eq 0 ]
then
	echo -e "(No Change) \c"
else
	echo "ms-dns $ms_dns_1" >> /etc/ppp/pptpd-options
	echo "ms-dns $ms_dns_2" >> /etc/ppp/pptpd-options
fi
CheckResult

# Add User
pInfo "[ Add user: /etc/ppp/chap-secrets ] \t... \c"
grep "${v_username}" /etc/ppp/chap-secrets > /dev/null
if [ $? -eq 0 ]
then
	echo -e "(No Change) \c"
else
	echo "${v_username}    pptpd    ${v_password}    *" >> /etc/ppp/chap-secrets
fi
CheckResult

# /etc/sysctl.conf
pInfo "[ Config /etc/sysctl.conf ] \t... \c"
grep "net.ipv4.ip_forward=1" /etc/sysctl.conf | grep -v "#" > /dev/null
if [ $? -eq 0 ]
then
	echo -e "(No Change) \c"
else
	echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
fi
CheckResult

# restart pptpd
pInfo "[ restart pptpd ]"
/etc/init.d/pptpd restart

# set ip_forward
pInfo "[ sysctl -p ]"
sysctl -p

# set iptables
RunCmd "iptables -t nat -A POSTROUTING -s ${iptables_s} -o ${iptables_o} -j MASQUERADE"

# Write iptables to startup.
pInfo "[ iptables-save > /etc/iptables-rules ]"
iptables-save > /etc/iptables-rules

# /etc/network/interfaces
pInfo "[ Config /etc/network/interfaces ] \t... \c"
grep "pre-up iptables-restore < /etc/iptables-rules" /etc/network/interfaces > /dev/null
if [ $? -eq 0 ]
then
	echo -e "(No Change) \c"
else
	echo "# Please make sure the following 1 line is under 'auto eth0'" >> /etc/network/interfaces
	echo "pre-up iptables-restore < /etc/iptables-rules" >> /etc/network/interfaces
fi
CheckResult
vim /etc/network/interfaces
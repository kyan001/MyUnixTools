#!/usr/bin/env bash
#
#=================================================================
# AutoCreateUser.sh
#   Create user automatically.
#=================================================================
#

#--Variables Defination-------------------------------------------
# Normal Bold Underline Gray Red Purple BLUE
VN="\e[0m";VB="\e[1m";VU="\e[4m";VG="\e[2m";VR="\e[31m";VP="\e[35m";VBLUE="\e[34m";

#--Common Macros--------------------------------------------------
Bold(){ echo -e "${VB}$1${VN}"; }
pWarn(){ echo -e "${VB}${VU}[WARNING]${VN}${VU}$1${VN}"; }
pErr(){ echo -e "${VB}${VR}[ERROR] $1${VN}" 1>&2; }
pInfo(){ echo -e "${VB}${VU}[INFO]${VN} $1"; }
pInfoGray(){ echo -e "${VB}${VG}${VU}[INFO]${VN} ${VG}$1${VN}"; }
Usage(){
	echo ""
	Bold "Usage:"
	echo -e "\t$0 -u/ser <USERNAME>"
	echo -e "\t$0 -u/ser <USERNAME> -del/ete"
	echo -e "\t$0 -help"
	echo ""
	echo "1. Must executed under ROOT user."
	echo "2. Use -del/ete option to delete user, otherwise will create."
	echo "3. Enter your password yourself."
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
if [ $# = 0 ]
then
	pErr "No parameters detected."
	Usage
	exit 1
fi

if [ "$(whoami)" != "root" ]
	then	pErr "This shell must be done in ROOT user!"
	exit 1
fi

#--Flags----------------------------------------------------------
delete_flag=0;
user_exist_flag=0;

#--Variables------------------------------------------------------
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
	-del | -delete)
		delete_flag=1;
		shift
		;;
	*)
		pErr "Wrong parameter: $1";
		shift
		;;
	esac
done

#--Main-----------------------------------------------------------
# Check if user already exist

if "grep '${v_username}' /etc/passwd > /dev/null"
	then	user_exist_flag=1
fi

if [ $delete_flag -eq 1 ]
then
	if [ $user_exist_flag -eq 1 ]
	then
		RunCmd "userdel -r ${v_username}"
		pWarn " Remove sudo by \"sudo vim /etc/sudoers\""
		exit 0
	fi
else
	if [ $user_exist_flag -eq 1 ]
	then
		pErr "User $v_username already exists!"
		exit 1
	else
		# Add user
		RunCmd "useradd ${v_username} -d /home/${v_username}/"

		# Set user password
		pInfo "[ passwd ${v_username} ]"
		passwd "${v_username}"

		# Make user home folder"
		RunCmd "mkdir /home/${v_username}/"
		RunCmd "chown ${v_username} /home/${v_username}/"

		# Make user sudoer
		pInfo "[ Write /etc/sudoers file ] \t... \c"
		echo "${v_username} ALL=(ALL:ALL) ALL" >> /etc/sudoers
		CheckResult

		# Set Default user shell = tcsh
		pInfo "If you need change the default shell, use 'chsh -s /bin/tcsh ${v_username}'"

		# Set up config files
		echo "Please run UpdateConfig.py manually after login."
	fi
fi

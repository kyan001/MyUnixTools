#!/bin/bash
#
#=================================================================
# AutoCreateUser.sh
#   Create user automatically.
#
# HISTORY
#-----------------------------------------------------------------
#     DATE    |     AUTHOR     |  VERSION | COMMENT
#-------------+----------------+----------+-----------------------
#  2013-11-01 |     YAN Kai    |   V1.0   | Script Creation
#  2013-11-03 |     YAN Kai    |   V1.1   | Add .vimrc support
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
	echo -e "\t$0 -u/ser <USERNAME> -del/ete"
	echo -e "\t$0 -help"
	echo ""
	echo "1. Must executed under ROOT user."
	echo "2. Use -del/ete option to delete user, otherwise will create."
	echo "3. Enter your password yourself."
	echo "4. Make sure ${KyanToolKit_Unix_Folder} exsits."
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

if [ `whoami` != "root" ]
	then	pErr "This shell must be done in ROOT user!"
	exit 1
fi

#--Flags----------------------------------------------------------
delete_flag=0;
user_exsit_flag=0;

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
# Check if user already exsit
grep "${v_username}" /etc/passwd > /dev/null
if [ $? -eq 0 ]
	then	user_exsit_flag=1
fi

if [ $delete_flag -eq 1 ]
then
	if [ $user_exsit_flag -eq 1 ]
	then
		RunCmd "userdel -r ${v_username}"
		pWarn " Remove sudo by \"sudo vim /etc/sudoers\""
		exit 0
	fi
else
	if [ $user_exsit_flag -eq 1 ]
	then
		pErr "User $v_username already exsits!"
		exit 1
	else
		# Add user
		RunCmd "useradd ${v_username} -d /home/${v_username}/"

		# Set user password
		pInfo "[ passwd ${v_username} ]"
		passwd ${v_username}

		# Make user home folder"
		RunCmd "mkdir /home/${v_username}/"
		RunCmd "chown ${v_username} /home/${v_username}/"

		# Create user .tcshrc
		RunCmd "touch /home/${v_username}/.tcshrc"
		RunCmd "chown ${v_username} /home/${v_username}/.tcshrc"
		pInfo "[ Write .tcshrc file ] \t... \c"
		echo "source .aliases_${v_username}" > /home/${v_username}/.tcshrc
		CheckResult

		# Make user sudoer
		pInfo "[ Write /etc/sudoers file ] \t... \c"
		echo "${v_username} ALL=(ALL:ALL) ALL" >> /etc/sudoers
		CheckResult

		# Set Default user shell = tcsh
		RunCmd "chsh -s /bin/tcsh ${v_username}"

		# Create user asliases file
		RunCmd "touch /home/${v_username}/.aliases_${v_username}"
		RunCmd "chown ${v_username} /home/${v_username}/.aliases_${v_username}"
		pInfo "[ Write /home/${v_username}/.aliases_${v_username} file ] \t... \c"
		python3 "${KyanToolKit_Unix_Folder}/UpdateAliases.py ${v_username}"
		CheckResult

		# Create user .vimrc file
		RunCmd "touch /home/${v_username}/.vimrc"
		RunCmd "chown ${v_username} /home/${v_username}/.vimrc"
		pInfo "[ Write /home/${v_username}/.vimrc file ] \t... \c"
		echo "\" Line number" > /home/${v_username}/.vimrc
		echo "set nu" >> /home/${v_username}/.vimrc
		echo "\" Column number" >> /home/${v_username}/.vimrc
		echo "set ruler" >> /home/${v_username}/.vimrc
		echo "\" ignore case when search" >> /home/${v_username}/.vimrc
		echo "\"set ic" >> /home/${v_username}/.vimrc
		echo "\" tab is 4 spaces long" >> /home/${v_username}/.vimrc
		echo "\"set ts=4" >> /home/${v_username}/.vimrc
		echo "\" highlight search result" >> /home/${v_username}/.vimrc
		echo "set hls" >> /home/${v_username}/.vimrc
		echo "\" highlight line and column" >> /home/${v_username}/.vimrc
		echo "\"set cuc" >> /home/${v_username}/.vimrc
		echo "\"set cul" >> /home/${v_username}/.vimrc
		echo "\" autoindent and smartindent" >> /home/${v_username}/.vimrc
		echo "set ai " >> /home/${v_username}/.vimrc
		echo "set si" >> /home/${v_username}/.vimrc
		echo "\" show match brackets" >> /home/${v_username}/.vimrc
		echo "set sm" >> /home/${v_username}/.vimrc
		echo "\" search as you type (incsearch)" >> /home/${v_username}/.vimrc
		echo "set is" >> /home/${v_username}/.vimrc
		echo "\" Show Tab Line(0=no,1=tab>2,2=always)" >> /home/${v_username}/.vimrc
		echo "set showtabline" >> /home/${v_username}/.vimrc
		CheckResult
	fi
fi

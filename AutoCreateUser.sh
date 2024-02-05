#!/usr/bin/env bash
#
#=================================================================
# AutoCreateUser.sh
#   Create user automatically.
#=================================================================

source ./pprint.sh


Usage(){
	pprint ""
	pprint --title "Usage:"
	pprint "    $0 -u/ser <USERNAME>"
	pprint "    $0 -u/ser <USERNAME> -del/ete"
	pprint "    $0 -help"
	pprint ""
	pprint "1. Must executed under ROOT user."
	pprint "2. Use -del/ete option to delete user, otherwise will create."
	pprint "3. Enter your password yourself."
	pprint ""
	exit 0
}

CheckResult(){
	if [ $? -eq 0 ]
	then pprint --info "Done"
	else pprint --err "Failed"
	fi
}

RunCmd(){
	pprint --info "\`$1\` ..."
	$1
	CheckResult
}

#--Preconditions--------------------------------------------------
if [ $# = 0 ]
then
	pprint --err "No parameters detected."
	Usage
	exit 1
fi

if [ "$(whoami)" != "root" ]
then
	pprint --err "This shell must be done in ROOT user!"
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
		pprint --err "Wrong parameter: $1";
		shift
		;;
	esac
done

#--Main-----------------------------------------------------------
# Check if user already exist

if "grep '${v_username}' /etc/passwd > /dev/null"
then user_exist_flag=1
fi

if [ $delete_flag -eq 1 ]
then
	if [ $user_exist_flag -eq 1 ]
	then
		RunCmd "userdel -r ${v_username}"
		pprint --warn " Remove sudo by \"sudo vim /etc/sudoers\""
		exit 0
	fi
else
	if [ $user_exist_flag -eq 1 ]
	then
		pprint --err "User $v_username already exists!"
		exit 1
	else
		# Add user
		RunCmd "useradd ${v_username} -d /home/${v_username}/"

		# Set user password
		RunCmd "passwd ${v_username}"

		# Make user home folder"
		RunCmd "mkdir /home/${v_username}/"
		RunCmd "chown ${v_username} /home/${v_username}/"

		# Make user sudoer
		pprint --title "\`Write /etc/sudoers file\` ..."
		echo "${v_username} ALL=(ALL:ALL) ALL" >> /etc/sudoers
		CheckResult

		# Set Default user shell = tcsh
		pprint --info "If you need change the default shell, use \`chsh -s /bin/tcsh ${v_username}\`"

		# Set up config files
		pprint --warn "Please run UpdateConfig.py manually after login."
	fi
fi

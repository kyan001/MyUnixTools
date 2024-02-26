#!/usr/bin/env bash
#
#=================================================================
# AutoCreateUser.sh
#   Create user automatically.
#=================================================================

source ./pprint.sh


Usage(){
	pprint ""
	pprint --panel "Usage"
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
	local result=$?
	if [ $result -eq 0 ]
	then pprint --info "Command Done"
	else pprint --err "Command Failed"
	fi
	return $result
}

RunCmd(){
	pprint --code "\`$1\`"
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
# Check if user already exists
if id "$username" >& /dev/null
then  # User exists
	if [ $delete_flag -eq 1 ]
	then
		RunCmd "userdel -r ${v_username}"
		pprint --warn "Remove sudo by \"sudo vim /etc/sudoers\""
		exit 0
	else
		pprint --err "User $v_username already exists!"
		exit 1
	fi
else  # User not exists
	if [ $delete_flag -eq 1 ]
	then
		pprint --err "User $v_username not exists!"
		exit 1
	else
	# Add user
	RunCmd "useradd ${v_username} -d /home/${v_username}/"

	# Set user password
	RunCmd "passwd ${v_username}"
	if [ $? -ne 0 ]
	then
		pprint --err "Failed to set password for user ${v_username}"
		RunCmd "userdel -r ${v_username}"
		exit 1
	fi

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
	pprint --panel "Please run configurator.py manually after login."
	fi
fi

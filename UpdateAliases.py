#!/usr/bin/python3
#
#=================================================================
# UpdateAliases.py
#   update users /home/{user}/.aliases_{user}
#
# HISTORY
#-----------------------------------------------------------------
#     DATE    |     AUTHOR     |  VERSION | COMMENT
#-------------+----------------+----------+-----------------------
#  2014-05-08 |     YAN Kai    |   V1.0   | Script Creation
#             |                |          |
#-----------------------------------------------------------------
#=================================================================
#
import os
import sys
import KyanToolKit_Py
import getpass
ktk = KyanToolKit_Py.KyanToolKit_Py()
user = getpass.getuser()

#--Pre-conditions Check-------------------------------------------
ktk.needPlatform("linux");
#--get user-------------------------------------------------------
if len(sys.argv) <= 1:
	ktk.Warn("User not passed, using current user.")
else:
	user = sys.argv[1]
alias_file = "/home/" + user + "/.aliases_" + user
ktk.info("User = " + user)
ktk.info("File = " + alias_file)
#--touch file and change owner-----------------------------------
if not os.path.exists(alias_file):
	ktk.info(alias_file + " not exists. Create one")
	ktk.runCmd("touch " + alias_file)
	ktk.runCmd("chown " + user + " " + alias_file)
else:
	ktk.info(alias_file + " already exists")
#--write file----------------------------------------------------
# \!:1 = 1st argument
alias_template = """# -----
# basic commands
alias ll 'ls -lh'
alias lsgp 'ls | grep -i'
alias llgp 'll | grep -i'
alias fd 'find -L . -name "\!:1"'
alias newa 'source /home/${v_username}/.aliases_${v_username}'
alias hgp 'history | grep -i --color'
# 3rd Party Tools
alias py 'python3'
alias startvnc 'vnc4server -geometry 1350x700'
alias stopvnc 'vnc4server -kill'
alias gvim '/usr/bin/gvim -p'
# KyanToolKit_Unix Tools
alias gp '${KyanToolKit_Unix_Folder}/EasyGrep.sh -i --color'
alias PWD '${KyanToolKit_Unix_Folder}/ClearAndPwd.sh -noclear -nolist'
alias LS '${KyanToolKit_Unix_Folder}/ClearAndPwd.sh -noclear'
source '${KyanToolKit_Unix_Folder}/PurePrompt.SourceMe'
# -----"""
# alias arg def
KyanToolKit_Unix_Folder="/home/kyan001/KyanToolKit_Unix"
v_username = user
# file open
a_file = open(alias_file,'w')
# replace variables
final_string = alias_template.replace("${v_username}",v_username).replace("${KyanToolKit_Unix_Folder}",KyanToolKit_Unix_Folder)
# write and close
a_file.write(final_string)
a_file.close()
ktk.info("Done. Enjoy.")

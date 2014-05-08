#!/usr/bin/python3
#
#=================================================================
# UpdateVimrc.py
#   update users /home/{user}/.vimrc
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
if not "linux" in sys.platform:
	ktk.Err("platform not linux, is " + sys.platform)
	sys.exit()
#--get user-------------------------------------------------------
if len(sys.argv) <= 1:
	ktk.Warn("User not passed, using current user.")
else:
	user = sys.argv[1]
vimrc_file = "/home/" + user + "/.vimrc"
ktk.Info("User = " + user)
ktk.Info("File = " + vimrc_file)
#--touch file and change owner-----------------------------------
if not os.path.exists(vimrc_file):
	ktk.Info(vimrc_file + " not exists. Create one")
	ktk.RunCmd("touch " + vimrc_file)
	ktk.RunCmd("chown " + user + " " + vimrc_file)
else:
	ktk.Info(vimrc_file + " already exists")
#--write file----------------------------------------------------
# \!:1 = 1st argument
vimrc_template = """\" -----
\" --Line number
set nu
\" --Column number
set ruler
\" --ignore case when search
\"set ic
\" --tab is 4 spaces long
\"set ts=4
\" --highlight search result
set hls
\" --highlight line and column
\"set cuc
\"set cul
\" --autoindent and smartindent
set ai
set si
\" --show match brackets
set sm
\" --search as you type (incsearch)
set is
\" --Show Tab Line(0=no,1=tab>2,2=always)
set showtabline
\" -----"""
# vimrc arg def

# file open
v_file = open(vimrc_file,'w')
# replace variables
final_string = vimrc_template
# write and close
v_file.write(final_string)
v_file.close()
ktk.Info("Done. Enjoy.")

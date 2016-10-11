#!/usr/bin/python3
#
# ================================================================
# UpdateVimrc.py
#   update users /home/{user}/.vimrc
#
# HISTORY
# ----------------------------------------------------------------
#     DATE    |     AUTHOR     |  VERSION | COMMENT
# ------------+----------------+----------+-----------------------
#  2014-05-08 |     YAN Kai    |   V1.0   | Script Creation
#             |                |          |
# ----------------------------------------------------------------
# ================================================================
#
import os
import sys
import getpass

import consoleiotools as cit
import KyanToolKit
ktk = KyanToolKit.KyanToolKit()
user = getpass.getuser()

# -Pre-conditions Check-------------------------------------------
ktk.needPlatform("linux")
# -get user-------------------------------------------------------
if len(sys.argv) <= 1:
    cit.warn("User not passed, using current user.")
else:
    user = sys.argv[1]
vimrc_file = "/home/" + user + "/.vimrc"
cit.info("User = " + user)
cit.info("File = " + vimrc_file)
# -touch file and change owner-----------------------------------
if not os.path.exists(vimrc_file):
    cit.info(vimrc_file + " not exists. Create one")
    ktk.runCmd("touch " + vimrc_file)
    ktk.runCmd("chown " + user + " " + vimrc_file)
else:
    cit.info(vimrc_file + " already exists")
# -write file----------------------------------------------------
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
set showtabline=1
\" -----"""
# vimrc arg def

# file open
v_file = open(vimrc_file, 'w')
# replace variables
final_string = vimrc_template
# write and close
v_file.write(final_string)
v_file.close()
cit.info("Done. Enjoy.")

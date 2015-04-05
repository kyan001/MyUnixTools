#!/usr/bin/python3
#
#=================================================================
# UpdateAliases.py
#   update users /home/{user}/.tcshrc
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
    ktk.warn("User not passed, using current user.")
else:
    user = sys.argv[1]
tcshrc_file = "/home/" + user + "/.tcshrc";
aliases_file = "/home/" + user + "/.aliases_" + user;
ktk.info("User = " + user)
ktk.info(".tcshrc File = " + tcshrc_file)
ktk.info(".aliases File = " + aliases_file)
#--touch file and change owner-----------------------------------
if not os.path.exists(tcshrc_file):
    ktk.info(tcshrc_file + " not exists. Create one")
    ktk.runCmd("touch " + tcshrc_file)
    ktk.runCmd("chown " + user + " " + tcshrc_file)
else:
    ktk.info(tcshrc_file + " already exists")
#--write file----------------------------------------------------
final_string = "source '" + aliases_file;
t_file = open(tcshrc_file,'w')
t_file.write(final_string)
t_file.close()
ktk.info("Done. Enjoy.")

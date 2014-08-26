#!/usr/bin/python3
#
#=================================================================
# UpdateUbuntu.py
#   Simply run sudo apt-get update / upgrade
#
# HISTORY
#-----------------------------------------------------------------
#     DATE    |     AUTHOR     |  VERSION | COMMENT
#-------------+----------------+----------+-----------------------
#  2014-03-10 |     YAN Kai    |   V1.0   | Script Creation
#             |                |          |
#-----------------------------------------------------------------
#=================================================================
#
import sys
import KyanToolKit_Py

#--Pre-conditions Check-------------------------------------------
if not "linux" in sys.platform:
	sys.exit()
ktk = KyanToolKit_Py.KyanToolKit_Py()

#--Update & Upgrade-----------------------------------------------
ktk.runCmd("sudo apt-get update")
ktk.runCmd("sudo apt-get upgrade")

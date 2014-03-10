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
import os
import sys

#--Pre-conditions Check-------------------------------------------
if not "linux" in sys.platform:
	sys.exit()

#--Update & Upgrade-----------------------------------------------
os.system("sudo apt-get update")
os.system("sudo apt-get upgrade")

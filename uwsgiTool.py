#!/usr/bin/python3
#
#=================================================================
# uwsgiTool.py
#
# HISTORY
#-----------------------------------------------------------------
#     DATE    |     AUTHOR     |  VERSION | COMMENT
#-------------+----------------+----------+-----------------------
#  2015-01-13 |     YAN Kai    |   V1.0   | Script Creation
#             |                |          |
#-----------------------------------------------------------------
#=================================================================
#
import os
import sys
import KyanToolKit_Py
ktk = KyanToolKit_Py.KyanToolKit_Py()

#--Pre-conditions Check-------------------------------------------
ktk.needPlatform("linux");
#--get user-------------------------------------------------------
ktk.needUser("root");
#--set params-----------------------------------------------------
uwsgi_xml="/var/www/portal/uwsgi.xml"
pid_file="/tmp/uwsgi.pid"
operations=["start","stop","reload"];
oprtn="";
if len(sys.argv) != 1:
    oprtn = ktk.getChoice(operations);
else if sys.argv[0] in operations:
    oprtn = sys.argv[0];
else:
    ktk.err("Wrong Params: " + sys.argv[0]);
    ktk.byeBye();

if "start" == oprtn:
    ktk.runCmd("sudo uwsgi -x '" + uwsgi_xml +"' --pidfile '" + pid_file + "' &");
else if "stop" == oprtn:
    ktk.runCmd("sudo uwsgi --stop " + pid_file);
else if "reload" == oprtn:
    ktk.runCmd("sudo uwsgi --reload " + pid_file);
else:
    ktk.err("Wrong operation: " + oprtn);
    ktk.byeBye();

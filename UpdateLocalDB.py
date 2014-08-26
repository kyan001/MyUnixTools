#!/usr/bin/python3
#=================================================================
# Only use to update local DB from x-one.cc
# MariaDB Only
#=================================================================

import KyanToolKit_Py;
import datetime;

ktk = KyanToolKit_Py.KyanToolKit_Py();
ktk.needPlatform("win");
ktk.needUser("Kyan");


time_now = datetime.datetime.strftime(datetime.datetime.now(),'%Y%m%d-%H%M%S');
prefix = "tickets_";
append = ".sql"
sql_file_name = prefix + time_now + append;
ktk.info(sql_file_name);

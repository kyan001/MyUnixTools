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

db_bakcup_file_name = datetime.datetime.now();
ktk.info(db_bakcup_file_name);

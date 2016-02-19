#!/usr/bin/python3
#
# Auto Parse Dante Log
#
# HISTORY
#-----------------------------------------------------------------
#     DATE    |     AUTHOR     |  VERSION | COMMENT
#-------------+----------------+----------+-----------------------
#  2016-02-19 |     YAN Kai    |   V1.0   | Script Creation
#             |                |          |
#-----------------------------------------------------------------
#
import re, os, KyanToolKit_Py
ktk = KyanToolKit_Py.KyanToolKit_Py()
log_path = '/var/log/dante.log'
if not os.path.exists(log_path):
    ktk.err("Please enter a valid log path.")
    ktk.bye()
clients = {}
with open(log_path) as f:
    for ln in f:
        pattern = re.compile(r': ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+).*45\.32\.45\.176\.10080')
        matches = pattern.findall(ln)
        if matches:
            key = matches[1]
            value = clients.setdefault(key, 0)
            clients[key] = value + 1
print("\nTotal: {} clients:".format(len(clients)))
print(clients)

#!/usr/bin/python3
#
# Auto Parse Dante Log
#
import re, os, KyanToolKit_Py
ktk = KyanToolKit_Py.KyanToolKit_Py()

log_path = '/var/log/dante.log'
backup_path = '/var/log/dante.log.backup'
if not os.path.exists(log_path):
    ktk.err("Please enter a valid log path.")
    ktk.bye()

# go through the log
clients = {}
with open(log_path) as f:
    for ln in f:
        pattern = re.compile(r': ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+).*45\.32\.45\.176\.10080')
        matches = pattern.findall(ln)
        if matches:
            key = matches[0]
            value = clients.setdefault(key, 0)
            clients[key] = value + 1

# print
clients_count = len(clients)
if clients_count == 0:
    ktk.err("0 client logged").bye()
print(ktk.banner("Total: {} clients:".format(clients_count)))

threshold = 5
print(ktk.banner("See clients lower than {} ?".format(threshold)))
see_all = ktk.getChoice(['Yes','No'])
if clients:
    for (k, v) in clients.items():
        if v < threshold and see_all == 'No':
            continue;
        if k == '173.230.148.199':
            k += ' (superfarmer.net)'
        if k == '106.186.20.163':
            k += ' (lnhote.me)'
        ktk.info("{} : {}".format(k, v))

# clear
print(ktk.banner(("Need clear the log?")))
need_clear = ktk.getChoice(['Yes','No'])
if "Yes" == need_clear:
    ktk.runCmd("sudo echo")
    if os.path.exists(backup_path):
        ktk.runCmd("sudo rm {}".format(backup_path))
        ktk.runCmd("sudo mv {log} {bck}".format(log=log_path, bck=backup_path))
        ktk.runCmd("sudo touch {}".format(log_path))
        ktk.runCmd("sudo chown proxyuser {}".format(log_path))
        ktk.info("Finish clear the log, old log @ {}".format(backup_path))

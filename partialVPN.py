#!/usr/bin／env python3
# http://tieba.baidu.com/p/3727427042

import consoleiotools as cit
import KyanToolKit
ktk = KyanToolKit.KyanToolKit()

ktk.needPlatform('win')
ip_list = [
    '80.239.173.156',
    '80.239.173.151',
    '184.50.87.33',
    '184.51.198.91',
    '184.51.198.73',
    '213.248.126.138',
    '213.248.126.137',
    '213.248.126.155',
    '111.108.54.16',
    '52.76.139.242',
]
if not ip_list:
    cit.err('Ip List is empty').bye()
vpn_route = '10.100.0.1'  # duetime
cit.info('VPN route = {}'.format(vpn_route))

# get mode, delete / set / print
available_modes = ['set', 'delete', 'print']
cit.ask("Choose mode:")
mode = cit.get_choice(available_modes)
if mode not in available_modes:
    cit.err('Mode {} is not supported, available modes: {}'.format(mode, available_modes)).bye()
cit.info('Mode = {}'.format(mode))

if mode == 'set':
    for ip in ip_list:
        cmd = 'route add {ip} mask 255.255.255.255 {vpn_route}'.format(vpn_route=vpn_route, ip=ip)
        ktk.runCmd(cmd)
elif mode == 'delete':
    for ip in ip_list:
        cmd = 'route delete {ip}'.format(ip=ip)
        ktk.runCmd(cmd)
elif mode == 'print':
    cmd = 'route print'
    ktk.runCmd(cmd)
cit.pause()

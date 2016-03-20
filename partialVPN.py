# http://tieba.baidu.com/p/3727427042

import KyanToolKit_Py, sys
ktk = KyanToolKit_Py.KyanToolKit_Py()

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
]
if not ip_list:
    ktk.err('Ip List is empty').bye()
vpn_route = '10.100.0.1' # duetime
ktk.info('VPN route = {}'.format(vpn_route))

# get mode, delete / set / print
available_modes = ['set', 'delete', 'print']
print(ktk.banner("Choose mode:"))
mode = ktk.getChoice(available_modes)
if mode not in available_modes:
    ktk.err('Mode {} is not supported, available modes: {}'.format(mode, available_modes)).bye()
ktk.info('Mode = {}'.format(mode))

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
ktk.pressToContinue()

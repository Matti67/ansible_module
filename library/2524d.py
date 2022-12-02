#!/usr/bin/env python3.6
##this program is a template about the way to save startup config to tftp server
##have a deep look on the way to save the switch config file 
##with a var which content is device hostname
from socket import timeout
#import pexpect
from io import StringIO
import time
import sys
import re
import os
import getopt
import subprocess
#import wexpect
#import termios
#set username e password
import pdb
import pexpect
#import struct, signal
host = input("insert ip address: ")
#print(host)
ssh_pass = 'xxxxxxxx'
#user = 'mng_reti'
#hostname = sys.argv[1]
getName =  subprocess.Popen("snmpget -v 2c -c pubrim {} sysName.0 | sed -n -e 's/^.*STRING: //p'".format(host), shell=True, stdout=subprocess.PIPE).stdout
hostname =  getName.read()
#remove last character from hostname content
buffer = StringIO()
sys.stdout = buffer
print(hostname.decode('ascii'))
sysname = buffer.getvalue()
sys.stdout = sys.__stdout__
#hostname = hostname[:-1]
#remove first character from hostname content
#hostname = hostname[1:]
#user1 = str(user)
#ip = '137.204.22.76'
child = pexpect.spawnu("plink -ssh mng_reti@{0}".format(host))
child.logfile = sys.stdout
child.delaybeforesend = 1
i=child.expect (['Continue', 'Store key', 'password:', 'Access granted', 'Press any key', '#'], timeout=4)
if i == 0:
    child.sendline('y')
elif i == 1:
    child.sendline('n')
elif i == 2:
    child.sendline(ssh_pass)
elif i == 3:
    child.sendline('  ')
elif i == 4:
    child.sendline('  ')
else:
    child.sendline('\r')
j=child.expect (['Continue', 'Store key', 'password:', 'Access granted', 'Press any key', '#'], timeout=4)
if j == 0:
    child.sendline('y')
elif j == 1:
    child.sendline('n')
elif j == 2:
    child.sendline(ssh_pass)
elif j == 3:
    child.sendline('  ')
elif j == 4:
    child.sendline('  ')
else:
    child.sendline('\r')
i=child.expect (['Continue', 'Store key', 'password:', 'Access granted', 'Press any key', '#'], timeout=4)
if i == 0:
    child.sendline('y')
elif i == 1:
    child.sendline('n')
elif i == 2:
    child.sendline(ssh_pass)
elif i == 3:
    child.sendline('  ')
elif i == 4:
    child.sendline('  ')
else:
    child.sendline('\r')
j=child.expect (['Continue', 'Store key', 'password:', 'Access granted', 'Press any key', '#'], timeout=4)
if j == 0:
    child.sendline('y')
elif j == 1:
    child.sendline('n')
elif j == 2:
    child.sendline(ssh_pass)
elif j == 3:
    child.sendline('  ')
elif j == 4:
    child.sendline('  ')
else:
    child.sendline('\r')
i=child.expect (['Continue', 'Store key', 'password:', 'Access granted', 'Press any key', '#'], timeout=4)
if i == 0:
    child.sendline('y')
elif i == 1:
    child.sendline('n')
elif i == 2:
    child.sendline(ssh_pass)
elif i == 3:
    child.sendline('  ')
elif i == 4:
    child.sendline('  ')
else:
    child.sendline('\r')
child.expect('#')
child.sendline('configure terminal')
child.expect('#')
child.sendline("no ip ssh filetransfer")
child.expect("#")
#
child.sendline("tftp client")
child.expect("#")
#
child.sendline("exit")
child.expect("#")
#
#hostname = child.after
#print(child.after)
#child.sendline('\r')
#hostname=child.read()
child.sendline('\r')
if child.before:
        child.expect (r'.+')
#child.read()
#k=child.expect (['#',pexpect.TIMEOUT, pexpect.EOF], timeout=2)
#if k == 0:
#    #
#    #child.before
#    #hostname=child.before
#    if child.before:
#        child.expect (r'.+')
#    #    
#else:
#    #hostname=child.before
#    if child.before:
#        child.expect (r'.+')
#    #child.read()
##
#hostname=child.after
#child.sendline(child.before)
#if child.before:
#        child.expect (r'.+')
child.expect("#")
#hostname=child.after
child.sendline('\r')
#k=child.expect ([pexpect.TIMEOUT, pexpect.EOF], timeout=2)
#if k == 0:
#    #
#    #child.before
#    #hostname=child.before
#    print('hostname=',hostname)
#    print(type(hostname))
#    child.sendline("copy startup-config tftp 137.204.22.33 {}".format(hostname))
#    #    
#else:
#    #hostname=child.before
#    print('hostname=',hostname)
#    print(type(hostname))
#    child.sendline("copy startup-config tftp 137.204.22.33 {}".format(hostname))
#    #child.read()
##
##hostname=child.after
child.expect("#")
print('hostname=',sysname)
print(type(hostname))
child.sendline("copy startup-config tftp 137.204.22.33 {}".format(sysname))
child.expect("#")
#tosee = child.before
#tosee = expect_out(buffer)
#print(child.before)
child.send ('exit\n')
time.sleep(1)
child.expect('>')
child.send ('\n')
child.sendline("logout")
child.expect(r'y/n')
child.sendline("y")
pass
child.close()
sys.exit()

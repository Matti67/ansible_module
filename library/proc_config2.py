#!/usr/bin/env python3.6
# -*- coding: utf-8 -*-

# Copyright: Contributors to the Ansible project
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)
from encodings import utf_8
import os
import getpass
import time
import sys
import re
import os
import getopt
import subprocess
import yaml
#import wexpect
#import termios
#set username e password
import pdb
import struct, signal

from socket import timeout
from ansible.module_utils.basic import AnsibleModule
import pexpect

DOCUMENTATION = '''
---
module: proc_facts

short_description: This is a custom module using pexpect to run commands in bash shell

description:
    - "This module runs commands inside a script in a shell. When run without commands it returns current settings only."

options:
    commands:
        description:
            - The commands to run inside myscript in order
        required: false
    options:
        description:
            - options to pass the script
        required: false
    timeout:
        description:
            - Timeout for finding the success string or running the program
        required: false
        default: 300
    password:
        description:
            - Password needed to run myscript
        required: true

author:
    - Brad Johnson - Keyva
'''

EXAMPLES = '''
- name: "Run myscript to set up myprogram"
  proc_facts:
    options: "-o myoption"
    host: "{{ ansible_host }}"
    ssh_user: "{{ ansible_ssh_user }}"
    ssh_pass: "{{ ansible_ssh_pass }}"
    commands:
      - "set minheap 1024m"
      - "set maxheap 5120m"
      - "set port 7000"
      - "set webport 80"
    timeout: 300
'''

RETURN = '''
current_settings: String containing current settings after last command was run and settings saved
    type: str
    returned: On success
logfile: String containing logfile location on the remote host from our script
    type: str
    returned: On success
'''


def main():
    # This is the import required to make this code an Ansible module
    #from ansible.module_utils.basic import AnsibleModule
    # This instantiates the module class and provides Ansible with
    # input argument information, it also enforces input types
    module = AnsibleModule(
        argument_spec=dict(
            commands=dict(required=False, type='list', default=[]),
            options=dict(required=False, type='str', default=""),
            host=dict(required=True, type='str', no_log=True),
            ssh_user=dict(required=True, type='str', no_log=True),
            ssh_pass=dict(required=True, type='str', no_log=True),
            timeparam=dict(required=False, type='int', default='300')
        )
    )
    commands = module.params['commands']
    options = module.params['options']
    host = module.params['host']
    ssh_user = module.params['ssh_user']
    ssh_pass = module.params['ssh_pass']
    timeparam = module.params['timeparam']

    try:
        # Importing the modules here allows us to catch them not being installed on remote hosts
        #   and pass back a failure via ansible instead of a stack trace.
        import pexpect
    except ImportError:
        module.fail_json(msg="You must have the pexpect python module installed to use this Ansible module.")

    try:
        # Run our pexpect function
        current_settings, changed, logfile = run_pexpect(commands, options, host, ssh_user, ssh_pass, timeparam)
        # Exit on success and pass back objects to ansible, which are available as registered vars
        module.exit_json(changed=changed, current_settings=current_settings, logfile=logfile)
    # Use python exception handling to keep all our failure handling in our main function
    except pexpect.TIMEOUT as err:
        module.fail_json(msg="pexpect.TIMEOUT: Unexpected timeout waiting for prompt or command: {0}".format(err))
    except pexpect.EOF as err:
        module.fail_json(msg="pexpect.EOF: Unexpected program termination: {0}".format(err))
    except pexpect.exceptions.ExceptionPexpect as err:
        # This catches any pexpect exceptions that are not EOF or TIMEOUT
        # This is the base exception class
        module.fail_json(msg="pexpect.exceptions.{0}: {1}".format(type(err).__name__, err))
    except RuntimeError as err:
        module.fail_json(msg="{0}".format(err))
    sys.exit()

def run_pexpect(commands, options, host, ssh_user, ssh_pass, time):
    #import pexpect
    changed = True
    '''script_path = '/path/to/myscript.sh'
    if not os.path.exists(script_path):
        raise RuntimeError("Error: the script '{0}' does not exist!".format(script_path))
    if script_path == '/path/to/myscript.sh':
        raise RuntimeError("This module example is based on a hypothetical command line interactive program and "
                           "can not run. Please use this as a basis for your own development and testing.")
    # Set prompt to expect with username embedded in it
    # YOU MAY NEED TO CHANGE THIS PROMPT FOR YOUR SYSTEM
    # My default RHEL prompt regex
    prompt = r'\[{0}\@.+?\]\$'.format(getpass.getuser())
    output = ""
    '''
    #ssh_user='mng_reti'
    #host='172.30.16.196'
    #ssh_pass='kS6n3GWS1xkr'
    child = pexpect.spawn('/usr/bin/plink -ssh {0}@{1}'.format(ssh_user,host), encoding='utf_8')
    #child = pexpect.spawn('/usr/bin/plink -ssh mng_reti@172.30.16.196')
    logf = open("/home/max/ansible/module/filelog" , "w")
    #child.logfile = sys.stdout
    child.logfile = logf
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
    #filelog = open("/home/max/ansible/module/filelog" , "w")
    #child.expect("Press any key to continue")
    #time.sleep(2)
    #child.logfile = sys.stdout
    temp_status = []
    child.sendline('configure terminal')
    child.expect('#')
    text_file = open(options, "r")
    #lines = text_file.read().split('@')
    lines = text_file.readlines()
    #print lines
    #print len(lines)
    #text_file.close()
    #with open('%s' % (os.environ["line"]),newline='\r') as csvfile:
    #    spamreader = csv.reader(csvfile, delimiter='@')
    for row in lines:#for line in ipfile:
        #child.sendline("interface %s" % (row))    # ISSUE IS HERE
        #child.expect("#")
        child.sendline("{}".format(row))
        #i=child.expect ([pexpect.TIMEOUT, pexpect.EOF], timeout=2)
        i=child.expect ([pexpect.TIMEOUT, pexpect.EOF, '#'], timeout=2)
        if i == 2:
            current_settings = child.before
            print (child.before)
            if child.before:
                child.expect (r'.+')
        #child.expect("#")
        #child.sendline("loop-protect trap loop-detected")
        #child.expect("#")
    text_file.close()
    child.sendline('\r')
    child.expect('#')
    child.sendline('exit')
    child.expect('#')
    hostname = child.after
    child.sendline('\r')
    child.expect('#')
    child.sendline("backup startup-configuration to 137.204.22.33 {}".format(hostname.cfg))
    child.expec('#')
    child.sendline('write memory')
    child.expect('#')
    # Note that child.before contains the output from the last expected item and this expect
    #current_settings = child.before.strip()
    #print((child.before), file=filelog)
    #print
    #logfile = "/var/log/ansible.log"
    logfile = "/home/max/ansible/module/filelog"
    #filelog.close()
    # Run the 'exit' command that is inside myscript
    child.sendline('exit')
    # Look for a linux prompt to see if we quit
    child.expect('>')
    child.sendline("logout")
    child.expect(r'y/n')
    child.sendline("y")
    #exit_status = child.before.split('\r\n')[1].strip()
    #pass
    logf.close()
    child.close()
    #sys.exit()
    return current_settings, changed, logfile

if __name__ == '__main__':
    main()


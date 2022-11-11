#!/usr/bin/env python3.6
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
module: my_module

short_description: This is a custom module using pexpect to run commands in myscript.sh

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
  my_module:
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
            time=dict(required=False, type='int', default='300')
        )
    )
    commands = module.params['commands']
    options = module.params['options']
    host = module.params['host']
    ssh_user = module.params['ssh_user']
    ssh_pass = module.params['ssh_pass']
    time = module.params['time']

    try:
        # Importing the modules here allows us to catch them not being installed on remote hosts
        #   and pass back a failure via ansible instead of a stack trace.
        import pexpect
    except ImportError:
        module.fail_json(msg="You must have the pexpect python module installed to use this Ansible module.")

    try:
        # Run our pexpect function
        current_settings, changed, logfile = run_pexpect(commands, options, host, ssh_user, ssh_pass, time)
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
    changed = False
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
    child = pexpect.spawn('/usr/bin/plink -ssh %s@%s' % (ssh_user,host), encoding='utf-8')
    #child = pexpect.spawn('/usr/bin/plink -ssh mng_reti@172.30.16.196')
    logf = open("/home/massimiliano/ansible_module/filelog" , "w")
    #child.logfile = sys.stdout
    child.logfile_read = logf
    child.delaybeforesend = 1
    try:
        child.expect('Continue')
        child.sendline('y')
    except:
        print('unable to start the connection')
    try:
        child.expect('Store key')
        child.sendline('n')
    except:
        print('storing key is mandatory')
    #k = child.expect([r'password:', r'yes/no'], timeout=12)
    try:
        child.expect('password:')
        #
        child.sendline(ssh_pass)
    except:
        print('unable to continue')
    #k = child.expect(['password:', r'yes/no'], timeout=time)
    '''if k==0:
        child.sendline(ssh_pass)
    else:
        child.sendline("yes")
        child.expect("assword:")
        child.sendline(ssh_pass)'''
    #time.sleep(3)
    #j = child.expect(['Access granted', r'>'], timeout=time)
    #if j==0: child.sendline('  ')
    try:
        child.expect('Access granted')
        child.sendline('  ')
    except:
        print('unable to continue')
    #
    try:
        child.expect(['Press any key'], timeout=time)
        child.sendline('  ')
    except:
        print('unable to continue')
    child.expect('#')
    logfile = "/home/massimiliano/ansible_module/filelog"
    #fileg = open("/home/massimiliano/ansible_module/filelog" , "w")
    #child.expect("Press any key to continue")
    #time.sleep(2)
    for command in commands:
        child.sendline(command)
        #i = child.expect([r'ERROR.+?does not exist', r'ERROR.+?$', '#'])
        i=child.expect ([pexpect.TIMEOUT, pexpect.EOF], timeout=2)
        if i == 0:
        # Attempt to intelligently add items that may have multiple instances and are missing
        # e.g. "socket.2" may need "add socket" run before it.
        # Try to allow the user just to use the set command and run add as needed
            try:
                new_item = child.after.split('"')[1].split('.')[0]
            except IndexError:
                raise RuntimeError("ERROR: unable to automatically add new item in myscript,"
                                    " file a bug\n  {0}".format(child.after))
            child.sendline('add {0}'.format(new_item))
            i = child.expect([r'ERROR.+?$', '>'])
            if i == 0:
                raise RuntimeError("ERROR: unable to automatically add new item in myscript,"
                                    " file a bug\n  {0}".format(child.after.strip()))
            # Retry the failed original command after the add
            child.sendline(command)
            i = child.expect([r'ERROR.+?$', '>'])
            if i == 0:
                raise RuntimeError("ERROR: unable to automatically add new item in myscript,"
                                    " file a bug\n  {0}".format(child.after.strip()))
        elif i == 1:
            raise RuntimeError("ERROR: unspecified error running a myscript command\n"
                                "  {0}".format(child.after.strip()))
        elif i == 2:
            # Set timeout shorter for final commands
            changed = False
            #print >>fileg, (child.before)
            #fileg.write(child.before)
            current_settings=child.before
            #print(child.before)
            #sys.stdout.flush()
            #print(child.before, f=fileg)
            #child.timeout = 1
            # If we processed any commands run the save function last
    #time.slee(5)
    #if commands:
    #    child.sendline('write memory')
    # Using true loops with expect statements allow us to process multiple items in a block until
    #    some kind of done or exit condition is met where we then call a break.
    '''while True:
        i = child.expect([r'No changes made', r'ERROR.+?$', '#'])
        if i == 0:
            changed = False
        elif i == 1:
            raise RuntimeError("ERROR: unexpected error saving configuration\n"
                                "  {0}".format(child.after.strip()))
        elif i == 2:
            break'''
            # Always print out the config data from out script and return it to the user
    #child.sendline('show running-config')
    #child.expect('#')
    # Note that child.before contains the output from the last expected item and this expect
    #current_settings = child.before
    #print(child.before, f=filelog)
    #print >>fileg, (child.before)
    #current_settings=child.before
    #print(child.before)
    #sys.stdout.flush()
    #fileg.close()
    '''fileg = open("/home/massimiliano/ansible_module/filelog" , "r")
    lines = fileg.readlines()
    limited_n_ints = ''
    for i in lines:
      limited_n_ints = limited_n_ints + i
    print(limited_n_ints)
    current_settings = limited_n_ints
    fileg.close()'''
    # Run the 'exit' command that is inside myscript
    child.sendline('exit')
    # Look for a linux prompt to see if we quit
    child.expect('>')
    #return current_settings, changed, logfile
    child.sendline("logout")
    child.expect(r'y/n')
    child.sendline("y")
    logf.close()
    child.close()
    #sys.exit()
    return current_settings, changed, logfile


if __name__ == '__main__':
    main()

#!/usr/bin/env python3.6
from socket import timeout
#import pexpect
import time
import sys
import re
import os
import getopt
import subprocess

#my_ip = input("insert ip address: ")
#print ("start")
#subprocess.call("/home/max/ansible/module/library/interfaces.sh {}".format(my_ip),shell=True )
#print ("end")
my_hexdata = input("insert hex string: ")
#
hexdata = my_hexdata.split()
#print (str(os.environ['list_int']))
scale = 16 ## equals to hexadecimal
num_of_bits = 8
for num_str in hexdata:
    res = bin(int(num_str, scale))[2:].zfill(num_of_bits)
    #Result = []
    #for i1, i2 in zip(res, os.environ['list_int']):
    #    Result.append(i1*i2)
   
 
    #print("The product of 2 lists is: ", Result)
    print ("Resultant string", str(res))
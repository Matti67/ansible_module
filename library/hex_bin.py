#!/usr/bin/env python3.6
#from ctypes.wintypes import RGB
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
#my_hexdata = input("insert hex string: ")
###with open("/home/max/ansible/module/procurve/untag3" , "r") as jfile:
###       #hex_vlans = jfile.split(";")
###       hexv = [line.rstrip(';') for line in jfile]
#
#hexdata = my_hexdata.split()
#idvlan = 0
i=0
with open("/home/max/ansible/module/procurve/vlans" , "r") as vfile:
       #list_vlans = list(vfile)
       list_vlans = [line.rstrip('\n') for line in vfile]
print (str(os.environ['list_int']))
lint = os.environ['list_int']
print (str(os.environ['vlan']))
vlid = os.environ['vlan']
print(vlid)
for index in range(len(list_vlans)):
 print(index, list_vlans[index])
 if list_vlans[index]==vlid:
   idvlan=index
print(idvlan)
#for idx, x in enumerate(list_vlans):
   #print(idx, x)
#   if x == vlid:
   #    idvlan = x
   #print(idx, x)
   #else:
   #    pass
#
int_list=lint.split()
print(int_list[1:4:1])
print(len(int_list))
print(idvlan)
vfile.close()
scale = 16 ## equals to hexadecimal
num_of_bits = 8
#print(hexv[0]) &>> /home/max/ansible/module/procurve/untag4
#jfile.close()
with open("/home/max/ansible/module/procurve/untag3" , "r") as jfile:
       #hex_vlans = jfile.split(";")
    hex_list = [line.rstrip(';') for line in jfile]
print(hex_list)
jfile.close()
mystring=''
for x in hex_list:
    mystring += ''+x
print(mystring)
hex_vlans=mystring.split(";")
with open("/home/max/ansible/module/procurve/untag4" , "w+") as vuntag:
    vuntag.write(mystring)
vuntag.close()
#with open("/home/max/ansible/module/procurve/untag4" , "r") as vuntag:
#    hex_vlans = vuntag.split(";")
#    #hex_vlans = [line.rstrip(';') for line in vuntag]
id=int(idvlan)
print(hex_vlans)
print(hex_vlans[id])
#for item in hex_vlans:
    #print(item, RGB)
#id=int(idvlan)
hex_field=hex_vlans[id].split()
#for num_str in hex_vlans[id]:
#for num_str in hex_field:
#    res = bin(int(num_str, scale))[2:].zfill(num_of_bits)
    #res = "{0:08b}".format(int(num_str, 16))
    #print(num_str,RGB)
#Result = []
#for i1, i2 in zip(res, os.environ['list_int']):
#    Result.append(i1*i2)
#print("The product of 2 lists is: ", Result)
#    print ("Resultant string", str(res))
Result = []
k=0
#for i1, i2 in zip(hex_field, lint):
for num_str in hex_field:
    res = bin(int(num_str, scale))[2:].zfill(num_of_bits)
    res_str=str(res)
    print(res_str[1])
    i=0
    while i < len(res_str):
        #print(i)       
        if ((res_str[i:i+1]=='1') and (k < len(int_list))):
            interface=int_list[k]
            #print(interface)
            Result.append(interface)
        i += 1
        k += 1
   #    Result.append(i1*i2)
 #i=i+1
 #print(i)
#jfile.close()
print("The interfaces untagged on vlan:",vlid,"are :",str(Result))
   #print("The product of 2 lists is: ", Result)
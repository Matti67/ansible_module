#!/usr/bin/env python3.10
from jinja2 import Template, Environment, FileSystemLoader, PackageLoader
import jinja2
import json
import os, signal
import sys
import re
import ast
import psutil
import yaml
import subprocess
import requests
import time
import datetime
from pathlib import Path
from re import findall
from subprocess import Popen, PIPE
#from pymongo import MongoClient, InsertOne, DeleteOne, UpdateOne, ReplaceOne
#from pymongo.errors import BulkWriteError
#from mongoengine import *
class CreateInv:

    def __init__(self, product='all', family_name=''):
        self.__iplist = []
        self.__family_items = []
        self.__family_device = ''
        self.__children = 'children'
        #self.__ansible_host = ''
        self.product = product # by default we retrieve all devices belonging to a macro family
        self.family_name = family_name # Select the macro family switchs name
        self.__NETBOX_URL = "https://netbox.unibo.it"  # Base URL of your NetBox instance
        self.__API_TOKEN = "4f8f22b92b7a119dc89f7725d88215e31345d2b5"  # API token for authorization
        self.__headers = {
            "Authorization": f"Token {self.__API_TOKEN}",
            "Content-Type": "application/json",
            "Accept": "application/json; indent=4"
        }
    # Define a custom function to serialize datetime objects 
    def __serialize_datetime(self, obj): 
        if isinstance(obj, datetime.datetime): 
            return obj.isoformat() 
        raise TypeError("Type not serializable") 
    #
    # Function to submit the job and get the job ID
    def __submit_familyjob(self, vendor):
        #NETBOX_URL = "https://netbox.unibo.it"  # Base URL of your NetBox instance
        #API_TOKEN = "4f8f22b92b7a119dc89f7725d88215e31345d2b5"  # API token for authorization
        # Define the script endpoint and payload
        FAMILY_ENDPOINT = "{}/api/extras/scripts/probe_hostname.ProbeHostName/".format(self.__NETBOX_URL)
        payload = {
            "data": {
                "devices": "{}".format(vendor)  # Adjust this value as needed
            },
            "commit": False
        }
        # Set up headers for authorization and content type
        response = requests.post(FAMILY_ENDPOINT, headers=self.__headers, json=payload)
        response.raise_for_status()  # Raise an error for any unsuccessful request
        familyjob_info = response.json()
        return familyjob_info["result"]["url"]  # Job URL to track progress

    def __submit_job(self):
        #
        SCRIPT_ENDPOINT = "{}/api/extras/scripts/prob_device_id.ProbeDeviceId/".format(self.__NETBOX_URL)
        jobload = {
            "data": {
                "items": "{}".format(all)  # Adjust this value as needed
            },
            "commit": False
        }
        res = requests.post(SCRIPT_ENDPOINT, headers=self.__headers, json=jobload)
        res.raise_for_status()  # Raise an error for any unsuccessful request
        job_info = res.json()
        return job_info["result"]["url"]  # Job URL to track progress


    # Function to poll job status
    def __poll_job(self, job_url):
        while True:
            job_response = requests.get(job_url, headers=self.__headers)
            job_response.raise_for_status()
            job_data = job_response.json()
            # Check if job has completed
            if job_data["status"]["value"] == "completed":
                return job_data  # Job is complete; return the result
            elif job_data["status"]["value"] == "failed":
                raise Exception(f"Job failed: {job_data.get('error', 'No error message provided')}")

            # Wait a few seconds before polling again
            time.sleep(2)

    #Function to test if switch device is active
    def __ping(self, switch, ping_count):
        #k=0
        #for ip in switch:
        data = ""
        print(switch)
        #output= Popen(f"ping {switch} -c {ping_count}", stdout=PIPE, encoding="utf-8")
        #getOutput = subprocess.Popen("ping -c 1 {} ".format(switch), shell=True, stdout=subprocess.PIPE).stdout
        #output = getOutput.read()
        #print(output)
        getOutput = subprocess.Popen("ping -c 1 {} ".format(switch), shell=True, stdout=subprocess.PIPE)
        output2 = getOutput.communicate()[0].decode("utf-8") 
        print(output2)
        #output = Popen(["ping", switch, "-c", str(ping_count)], stdout=PIPE, encoding="utf-8")
        SwitchActive = True
        SwitchOff = False
        #itemc = str(output)
        #di = itemc.replace("'", "\"")
        #vi = ast.literal_eval(di)
        ##for line in output.stdout:
        ##for line in output:
        ##    data = data + line
        ##    ping_test = findall("ttl", data)
        #data = data + vi
        ping_test = findall("ttl", output2)
        #ping_test = findall("ttl", data)
        if ping_test:
            print(f"{switch} : Successful Ping")
            return SwitchActive
        else:
            print(f"{switch} : Failed Ping")
            return SwitchOff
        #k += 1
    # Main execution
    def __retrieveIpList(self, vendor):
        #vendor = index_device
        try:
            # Submit the job
            job_url = self.__submit_familyjob(vendor)
            print(f"familyJob submitted successfully. Tracking URL: {job_url}")
            
            # Poll until job completion
            job_result = self.__poll_job(job_url)
            job_result1 = job_result.get("data")
            job_complete = job_result1['output']
            #iplist =[]
            addrlist = []
            #create a list with ip address as elements
            #for line in job_complete.split('\n'):
            #    element = line.rsplit(',',1)[1]
            #    #append the last delimeter element
            #    addrlist.append(element)
            ##create a list with just real ip address
            #for i in addrlist:
            #    if str(i[:1])=='1':
            #        self.__iplist.append(i)
            #
            for line in job_complete.split('\n'):
                sysname, element = line.rsplit(',', 1)  # Extract text and number
                addrlist.append({"elem": element, "sys": sysname})  # Structured JSON format
            #
            self.__iplist = [item for item in addrlist if item["elem"].startswith("1")]
            #self.__family_items2 =
            json_output = json.dumps(addrlist, indent=4)
            #straddr = str(job_complete)
            #job_complete.replace('\n', '\\n')
            #lines = job_complete.split('\\n')
            # Print the output
            print("Job completed. Output data:")
            #print(job_result.get("data", "No data returned from job."))
            #print(lines)
            print(job_complete)
            #print(*addrlist,sep='\n')
            print(*self.__iplist,sep='\n')
            return self.__iplist

        except Exception as e:
            print(f"An error occurred: {e}")
            

    def retrieveFamilySet(self):
        try:
            # Submit the job
            job_url = self.__submit_job()
            print(f"Job submitted successfully. Tracking URL: {job_url}") 
            # Poll until job completion
            job_result = self.__poll_job(job_url)
            job_result1 = job_result.get("data")
            job_complete = job_result1['output']
            family_list = []
            addrlist = []
            #create a list with ip address as elements
            #create a list with just real ip address
            for line in job_complete.split('\n'):
                family, index = line.rsplit(',', 1)  # Extract text and number
                family_list.append({"index": index, "family": family})  # Structured JSON format
            json_output = json.dumps(family_list, indent=4)
            self.__family_items = [item for item in family_list if item["family"].startswith("{}".format(self.family_name))]
            #self.__family_items2 = [item for item in family_list if item["family"].startswith("{}".format(self.family_name))]
            #self.__family_items = json.dumps(self.__family_items2, indent=4)
            print("Job completed. Output data:")
            print(json.dumps(self.__family_items, indent=4))
            print(f"this output is self.__family_items:  {self.__family_items}")
            for item in self.__family_items:
                #
                #for key, value in item.items():
                print(f"item[index] and item[family]:  {item[index]} {item[family]}")
            #return self.__family_items
        except Exception as e:
            print(f"An error occurred: {e}")
    
    #def __write_yaml_to_file(self, py_obj, filename):
    #    with open(f'{filename}.yml', 'w',) as f :
    #        yaml.dump(py_obj,f,sort_keys=Fafrom pathlib import Pathlse, default_style='"') 
    #    print('Written to file successfully')

    def __convert_ips(self, obj):
        if isinstance(obj, dict):
            return {k: self.__convert_ips(v) for k, v in obj.items()}
        elif isinstance(obj, list):
            return [self.__convert_ips(i) for i in obj]
        elif isinstance(obj, str) and obj.count('.') == 3 and all(part.isdigit() for part in obj.split('.')):
            return f'"{obj}"'  # Ensure IPs are treated as strings, without extra quotes
        return obj


    def __write_yaml_to_file(self, py_obj, filename):
        # Function to process and ensure IPs are strings
        dn =  Path.cwd()
        # Convert IP addresses while keeping other elements intact
        fixed_obj = self.__convert_ips(py_obj)
        ###
        output_path = os.path.join(dn,"inventory/")
        ###
        with open('{}/{}.yml'.format(output_path,filename), 'w') as f:
            #yaml.dump(fixed_obj, f, sort_keys=False, default_flow_style=False, allow_unicode=True, explicit_start=False)
            yaml.dump(fixed_obj, f, sort_keys=False)
        #f.close()
        with open('{}/{}.yml'.format(output_path,filename), 'r') as f:
            # Read the file contents into a single variable
            contents = f.read()
        #f.close()
        REGEX1 = re.compile(r"[']")
        new_contents = re.sub(REGEX1, '', contents)

        with open('{}/{}.yml'.format(output_path,filename), 'w') as f:
        # actually write the lines
            f.seek(0, 0)
            f.write('---'.rstrip('\r\n') + '\n' + new_contents)
            #f.write(new_contents)
        f.close()
        print('Written to file successfully')


    def writeInventory(self):
        if self.product != 'all':
            #
            data = {}
            for item in self.__family_items:
                #for key, value in item.items():
                #print(f"item[index] and item[family]:  {item[index]} {item[family]}")
                if item['index'] == self.product:
                    self.__family_device = item['family']
                    #print(f"the self.__fam_device is {self.__fam_device}")
            self.__iplist = self.__retrieveIpList(self.product)
            ## Ensure family_name is initialized as a dictionary
            ##if self.family_name not in data:
            ##    data[self.family_name] = {}
            ### Ensure fam_device is initialized as a dictionary
            ##if self.__children not in data[self.family_name]:
            ##    data[self.family_name][self.__children] = {}
            ##if self.__fam_device not in data[self.family_name][self.__children]:
            ##    data[self.family_name][self.__children][self.__fam_device] = {}
            ### update to avoiding both self.__family_name and self.__children to be part of data obj
            if self.__family_device not in data:
                data[self.__family_device] = {}
            #data[self.family_name]=self.__fam_device
            #data[self.family_name][self.__fam_device]={}
            for i, item in enumerate(self.__iplist):
                newhostname = item["sys"]
                ip = item["elem"]
                addr = str(ip)
                # Ensure the IP address is treated as a string
                ipcount = addr.strip()
                # Now pass `ipcount` directly to the `ping` function without `ast.literal_eval`
                check = self.__ping(ipcount, 1)
                #ipcount = addr.replace("'", "\"")
                #iplist2 = ast.literal_eval(ipcount)
                #check = ping(iplist2,1)
                if check == True:
                    #getHostName =  subprocess.Popen("snmpget -v 2c -c pubrim {} sysName.0 | sed -n -e 's/^.*STRING: //p'".format(ip), shell=True, stdout=subprocess.PIPE)
                    ##newhostname =  getHostName.read()
                    #hostname = getHostName.communicate()[0].decode("utf-8")
                    #newhostname = hostname.rstrip()
                    # Ensure "hosts" key is present
                    #if 'hosts' not in data[self.family_name][self.__children][self.__fam_device]:
                    #    data[self.family_name][self.__children][self.__fam_device]['hosts'] = {}
                    if 'hosts' not in data[self.__family_device]:
                        data[self.__family_device]['hosts'] = {}
                    #data[self.family_name][self.__fam_device][hosts][newhostname]={}
                    #data[self.family_name][self.__fam_device]['hosts'][newhostname]['ansible_host']='{}'.format(ip)
                    #data[self.family_name][self.__children][self.__fam_device]['hosts'][newhostname] = {
                    data[self.__family_device]['hosts'][newhostname] = {
                    #'ansible_host': "{}".format(ip)
                    'ansible_host': ip
                    }
            print(f"the objet data is : {data}")
            self.__write_yaml_to_file(data,self.__family_device)
        else:   
            data = {}
            #families = []
            #indexes = []
            #for item in self.__family_items:
            for i, item in enumerate(self.__family_items):
            #families = [item['family'] for item in self._family_items]
            #indexes = [item['index'] for item in self._family_items]
                families = item["family"]
                indexes = item["index"]
                self.__iplist = self.__retrieveIpList(indexes)
                #data[self.family_name]=families
                #data[self.family_name][families]={}
                if self.family_name not in data:
                    data[self.family_name] = {}
                # Ensure fam_device is initialized as a dictionary
                if self.__children not in data[self.family_name]:
                    data[self.family_name][self.__children] = {}
                if families not in data[self.family_name][self.__children]:
                    data[self.family_name][self.__children][families] = {}
                #data[self.family_name]=self.__fam_device
                for i, item in enumerate(self.__iplist):
                    newhostname = item["sys"]
                    ip = item["elem"]
                    addr = str(ip)
                    # Ensure the IP address is treated as a string
                    ipcount = addr.strip()
                    # Now pass `ipcount` directly to the `ping` function without `ast.literal_eval`
                    check = self.__ping(ipcount, 1)
                    #ipcount = addr.replace("'", "\"")
                    #iplist2 = ast.literal_eval(ipcount)
                    #check = ping(iplist2,1)
                    if check == True:
                        #getHostName =  subprocess.Popen("snmpget -v 2c -c pubrim {} sysName.0 | sed -n -e 's/^.*STRING: //p'".format(ip), shell=True, stdout=subprocess.PIPE)
                        ##newhostname =  getHostName.read()
                        #hostname = getHostName.communicate()[0].decode("utf-8")
                        #newhostname = hostname.rstrip()
                        #
                        if 'hosts' not in data[self.family_name][self.__children][families]:
                            data[self.family_name][self.__children][families]['hosts'] = {}
                        #data[self.family_name][families][hosts][newhostname]={}
                        data[self.family_name][self.__children][families]['hosts'][newhostname] = {
                        'ansible_host': ip
                        }
            self.__write_yaml_to_file(data,self.family_name)
               # print(f"{key}: {value}")

def main():

    ###Ask to input device model
    vendor = input("Select Device type id , default to all  ")
    ## Select macro family switchs
    family = input("Select macro family to retrieve  ")
    #family = str(family2)
    if vendor != 'all':
        createinv = CreateInv(product=vendor, family_name=family)
        #createinv.retrieveFamilySet()
        #createinv.writeInv()
    else:
        createinv = CreateInv(family_name=family)
        #createinv.retrieveFamilySet()

    createinv.retrieveFamilySet()
    createinv.writeInventory()

if __name__ == '__main__':
    main()


    #with open("/home/max/apinode/data/vhp3c.json" , "w") as filej_app:
    #            json.dump(datacheck, filej_app, indent=2) 

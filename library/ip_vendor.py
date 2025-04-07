#!/usr/bin/env python3.10
from jinja2 import Template, Environment, FileSystemLoader, PackageLoader
import jinja2
import json
import os, signal
import sys
import re
import ast
import psutil
import subprocess
import requests
import time
import datetime
from re import findall
from subprocess import Popen, PIPE
#from pymongo import MongoClient, InsertOne, DeleteOne, UpdateOne, ReplaceOne
#from pymongo.errors import BulkWriteError
#from mongoengine import *


# Definisco la connessione al database MongoDB
#client = MongoClient('mongodb://137.204.2.22:27018')
#client = MongoClient('mongodb://137.204.2.22:27018/?tls=true&tlsCAFile=%2Fhome%2Fmax%2Fmongocert%2Fssl%2Frootca.pem&tlsCertificateKeyFile=%2Fhome%2Fmax%2Fmongocert%2Fssl%2Fmongodb.pem')
iplist = []
# Define NetBox API details
NETBOX_URL = "https://netbox.unibo.it"  # Base URL of your NetBox instance
#API_TOKEN = "0fd274bf2d10f582c39fe7b8ebec1bf9750c7d26"  # API token for authorization
API_TOKEN = "4f8f22b92b7a119dc89f7725d88215e31345d2b5"  # API token for authorization
###Ask to input device model
type = input("Select Device type id to retrieve address IP ")
# Define the script endpoint and payload
#SCRIPT_ENDPOINT = f"{NETBOX_URL}/api/extras/scripts/probe_devrole.DeviceRole/"
SCRIPT_ENDPOINT = "{}/api/extras/scripts/probe_address.ProbeDevice/".format(NETBOX_URL)
payload = {
    "data": {
        "devices": "{}".format(type)  # Adjust this value as needed
    },
    "commit": True
}

# Set up headers for authorization and content type
headers = {
    "Authorization": f"Token {API_TOKEN}",
    "Content-Type": "application/json",
    "Accept": "application/json; indent=4"
}

# Define a custom function to serialize datetime objects 
def serialize_datetime(obj): 
    if isinstance(obj, datetime.datetime): 
        return obj.isoformat() 
    raise TypeError("Type not serializable") 
#
# Function to submit the job and get the job ID
def submit_job():
    response = requests.post(SCRIPT_ENDPOINT, headers=headers, json=payload)
    response.raise_for_status()  # Raise an error for any unsuccessful request
    job_info = response.json()
    return job_info["result"]["url"]  # Job URL to track progress

# Function to poll job status
def poll_job(job_url):
    while True:
        job_response = requests.get(job_url, headers=headers)
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
def ping (switch,ping_count):
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
try:
    # Submit the job
    job_url = submit_job()
    print(f"Job submitted successfully. Tracking URL: {job_url}")
    
    # Poll until job completion
    job_result = poll_job(job_url)
    job_result1 = job_result.get("data")
    job_complete = job_result1['output']
    #iplist =[]
    addrlist = []
    #create a list with ip address as elements
    for line in job_complete.split('\n'):
        element = line.rsplit(',',1)[1]
        #append the last delimeter element
        addrlist.append(element)
    #create a list with just real ip address
    for i in addrlist:
        if str(i[:1])=='1':
            iplist.append(i)
    #straddr = str(job_complete)
    #job_complete.replace('\n', '\\n')
    #lines = job_complete.split('\\n')
    # Print the output
    print("Job completed. Output data:")
    #print(job_result.get("data", "No data returned from job."))
    #print(lines)
    print(job_complete)
    #print(*addrlist,sep='\n')
    print(*iplist,sep='\n')

except Exception as e:
    print(f"An error occurred: {e}")
#
#Always check if the switch is active
k=0

#print(len(iplist))
#print(iplist)
#for k in range(len(iplist)):
#    #addr = str(iplist[k])
#    addr = str(iplist[k])
#    # Ensure the IP address is treated as a string
#    ipcount = addr.strip()
#    
#    # Now pass `ipcount` directly to the `ping` function without `ast.literal_eval`
#    check = ping(ipcount, 1)
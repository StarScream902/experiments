#!/usr/bin/env python3

from os import path
from sys import argv
import boto3

if len(argv) < 2:
    raise "Usage: %s path" % argv[0]

PATH = argv[1]
SSM = boto3.client('ssm')

fc = open('configs.yaml', 'w')
fc.close()
fs = open('secrets.yaml', 'w')
fs.write('secrets:\n')
fs.close()

def get_parameters_by_path(next_token):
    params = { 'Path': PATH, 'Recursive': True, 'WithDecryption': True }
    if next_token is not None:
        params['NextToken'] = next_token
    response = SSM.get_parameters_by_path(**params)
    parameters = response['Parameters']
    fc = open('configs.yaml', 'a')
    fs = open('secrets.yaml', 'a')
    for parameter in parameters:
        env_name = path.basename(parameter['Name'])
        env_value = parameter['Value']
        if parameter['Type'] == "String":
            fc.write(env_name+': '+env_value+'\n')
        elif parameter['Type'] == "SecureString":
            fs.write('  '+env_name+': '+env_value+'\n')
    fc.close()
    fs.close()
    try: # if we have this object in response
        response['NextToken']
    except: # do nothing
        next_token = None
    else: # get parameters again with nextToken
        next_token = response['NextToken']
        get_parameters_by_path(next_token)

if __name__ == "__main__":
    next_token = None
    get_parameters_by_path(next_token)

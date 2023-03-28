#!/usr/bin/env python

from os import path
from sys import argv
import boto3

if len(argv) < 2:
    raise "Usage: %s path" % argv[0]

PATH = argv[1]
SSM = boto3.client('ssm')

matches = ["key", "secret", "password"]

def get_parameters_by_path(next_token = None):
    params = {
        'Path': PATH,
        'Recursive': True,
        'WithDecryption': True
    }
    if next_token is not None:
        params['NextToken'] = next_token
    return SSM.get_parameters_by_path(**params)

def parameters():
    next_token = None
    while True:
        response = get_parameters_by_path(next_token)
        parameters = response['Parameters']
        if len(parameters) == 0:
            break
        for parameter in parameters:
            yield parameter
        if 'NextToken' not in response:
            break
        next_token = response['NextToken']

def print_env_vars(parameter):
    env_name = path.basename(parameter['Name'])
    env_value = parameter['Value']
    if not any(x in env_name.lower() for x in matches):
        print("%s: \"%s\"" % (env_name, env_value))

def main():
    for parameter in parameters():
        print_env_vars(parameter)

if __name__ == "__main__":
    main()

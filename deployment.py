from __future__ import print_function
import json
import boto3
import logging
import time
import datetime
import os
import subprocess
from get_regions import *

logger = logging.getLogger()
logger.setLevel(logging.INFO)

list_of_regions = get_custom_regions()

def deployment(list_of_regions):
	try:
		for regions in list_of_regions:
			print("Working on: ", regions)
			os.system('C:\\Java.net\\terraform_0.15.5_windows_amd64\\terraform apply -auto-approve -var="using_region={}"'.format(regions))
			print("Completed creation in region:{}".format(regions))
		return True
		
	except Exception as e:
		logger.error('Something went wrong: ' + str(e))
		return False


if __name__ == '__main__':
	try:
		list_of_regions = get_custom_regions()  # use get_all_regions for all the regions
		deployment(list_of_regions)
	
	except Exception as e:
		logger.error('Something went wrong: ' + str(e))
		


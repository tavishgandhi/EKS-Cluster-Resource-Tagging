from __future__ import print_function
import json
import boto3
import logging
import time
import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def get_custom_regions():
	try:
		list_of_regions = ["us-east-1", "us-east-2", "us-west-1"]
		return list_of_regions

	except Exception as e:
		logger.error('Something went wrong: ' + str(e))
		return False

def get_all_regions():
	try:
		# Code to fetch all regions
		# all_regions=[]
		# profile_name = "Tavish"
		# session = boto3.session.Session(profile_name=profile_name, region_name="us-east-1")
		# ec2_client = session.client(service_name="ec2")
		# for each_region in ec2_client.describe_regions()['Regions']:
		# 	all_regions.append(each_region.get('RegionName'))
		all_regions = ['eu-north-1', 'ap-south-1', 'eu-west-3', 'eu-west-2', 'eu-west-1', 'ap-northeast-3', 'ap-northeast-2', 'ap-northeast-1', 'sa-east-1', 'ca-central-1', 'ap-southeast-1', 'ap-southeast-2', 'eu-central-1', 'us-east-1', 'us-east-2', 'us-west-1', 'us-west-2']
		return all_regions

	except Exception as e:
		logger.error('Something went wrong: ' + str(e))
		return False

if __name__ == '__main__':
	regions = get_all_regions()
	if regions:
		print(regions)
		print(len(regions))
	else:
		print("Something went wrong")

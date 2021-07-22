from __future__ import print_function
import json
import boto3
import logging
import time
import datetime
from pprint import pprint

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info('Event: ' + str(event))
    print('Received event: ' + json.dumps(event, indent=2))

    ids = []

    try:
        region = event['region']
        detail = event['detail']
        eventname = detail['eventName']
        principal = detail['userIdentity']['principalId']
        userType = detail['userIdentity']['type']
        userAgent = detail['userAgent']

        # Printing details about the Event
        logger.info('principalId: ' + str(principal))
        logger.info('region: ' + str(region))
        logger.info('eventName: ' + str(eventname))
        logger.info('detail: ' + str(detail))
        logger.info('userAgent: ' + str(userAgent))

        # Check for Response
        if not detail['responseElements']:
            logger.warning('Not responseElements found')
            if detail['errorCode']:
                logger.error('errorCode: ' + detail['errorCode'])
            if detail['errorMessage']:
                logger.error('errorMessage: ' + detail['errorMessage'])
            return False

        if userType == 'IAMUser':
            user = detail['userIdentity']['userName']
        else:
            if userAgent == 'autoscaling.amazonaws.com':            # This is to check whether the userAgent is Autoscaling group
                nodegroupName = ''                                  # Initialising EKS Node-group-name.
                eksclusterName = ''                                 # Initialising EKS cluster name.

                items_Node = detail['responseElements']['instancesSet']['items'] # Drilling down event to find node-group name tag.
                for item in items_Node:
                    tagSet = item['tagSet']
                    for tags in tagSet['items']:
                        if tags['key'] == 'eks:nodegroup-name':     # Check if 'eks:nodegroup-name' tag exists, this means the instance is part of a EKS-Node-group
                            nodegroupName = tags['value']
                        if tags['key'] == 'eks:cluster-name':
                            eksclusterName = tags['value']

                SSM_prefix = '/NodeGroupNames/' + eksclusterName + "/"  # This is top hierarchy name for SSM parameter store
                                                                        # which further store Node group name as Key and its owner as value.
                logger.info('Node-group-name: ' + str(nodegroupName))
                logger.info('Eks-cluster-name: ' + str(eksclusterName))

                if len(nodegroupName) != 0:                         # If the instance is part of EKS-Node-group.
                    nodegroupOwner = SSM_prefix + nodegroupName     # Complete path of SSM "Node-group Name & Owner" parameter store.
                    ssm = boto3.client('ssm')                       # SSM client to retrive Node group owner name
                    ssm_response = ssm.get_parameter(Name=nodegroupOwner) # Fetching Owner name
                    user = ssm_response['Parameter']['Value']
                    logger.info('SSM Path: ' + str(nodegroupOwner))

            else:
                user = detail['userIdentity']['type']

        ec2 = boto3.resource('ec2')
        asg_ids = []
        items = detail['responseElements']['instancesSet']['items']

        # Appending Instance Ids
        for item in items:
            ids.append(item['instanceId'])


        logger.info(ids)
        logger.info('number of instances: ' + str(len(ids)))

        base = ec2.instances.filter(InstanceIds=ids)

        # loop through the instances
        for instance in base:
            for vol in instance.volumes.all():
                ids.append(vol.id)
            for eni in instance.network_interfaces:
                ids.append(eni.id)
            for sg in instance.security_groups:
                ids.append(sg['GroupId'])
            for tags in instance.tags:
                if tags['Key'] == 'aws:ec2launchtemplate:id':
                    ids.append(tags['Value'])

                if tags['Key'] == 'aws:autoscaling:groupName':
                    asg_ids.append(tags['Value'])
                    logger.info("tags : " + str(tags['Value']))
                    logger.info("asg : " + str(asg_ids))

            ids.append(instance.vpc_id)
            ids.append(instance.subnet_id)
        logger.info("asg : " + str(asg_ids))

        if ids:
            for resourceid in ids:
                print('Tagging resource ' + resourceid)
            ec2.create_tags(Resources=ids, Tags=[{'Key': 'CreatedBY', 'Value': user}])

        if asg_ids:
            asg_client = boto3.client('autoscaling')
            for resourceid in asg_ids:
                print('Tagging resource ' + resourceid)
                asg_response = asg_client.create_or_update_tags(
                    Tags=[
                        {
                            'ResourceId': resourceid,
                            'ResourceType': 'auto-scaling-group',
                            'Key': 'CreatedBY',
                            'Value': user,
                            'PropagateAtLaunch': True
                        }
                    ]
                )

        logger.info(' Remaining time (ms): ' + str(context.get_remaining_time_in_millis()) + '\n')
        return True
    except Exception as e:
        logger.error('Something went wrong: ' + str(e))
        return False

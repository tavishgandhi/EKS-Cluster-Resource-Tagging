from __future__ import print_function
import json
import boto3
import logging
import time
import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):

    # Fetching important information from event
    try:
        detail = event['detail']
        region = detail['awsRegion']
        eventName = detail['eventName']

        # If the given event contains a response Elements
        if not detail['responseElements']:
            logger.warning('No responseElements found')
            if event['errorCode']:
                logger.error('errorCode: ' + event['errorCode'])
            if event['errorMessage']:
                logger.error('errorMessage: ' + event['errorMessage'])
                return False
        else:
            eksclusterName = detail['responseElements']['nodegroup']['clusterName']
            nodegroupArn = detail['responseElements']['nodegroup']['nodegroupArn']
            nodegroupName = detail['responseElements']['nodegroup']['nodegroupName'] # Most Important variable

        # Fetching details about the principal
        principal = detail['userIdentity']['principalId']
        userType = detail['userIdentity']['type']

        if userType == 'IAMUser':
            user = detail['userIdentity']['userName']
        else:
            user = principal.split('/')[1]

        # Printing all the neccessary details
        logger.info('User: ' + str(user))
        logger.info('principalId: ' + str(principal))
        logger.info('region: ' + str(region))
        logger.info('eventName: ' + str(eventName))
        logger.info('eksclusterName: ' + str(eksclusterName))
        logger.info('nodegroupName: ' + str(nodegroupName))

        # Main logic component of the lambda function.
        # We have fetched the Node group name and User which created the node,
        # now inserting:-
        # Key = Node group Name && Value = user

        ssm = boto3.client('ssm')
        SSM_prefix = '/NodeGroupNames/' + eksclusterName + "/"
        Node_group_full_name = SSM_prefix + nodegroupName

        if eventName == "CreateNodegroup":
            response = ssm.put_parameter(
            Name=Node_group_full_name,
            Description='Adding Node_group_name as key and createdBy IAMUser as Value',
            Value=user,
            Type='String'
            )
            logger.info("Successfully created parameter")

        elif eventName == "DeleteNodegroup":
            response = ssm.delete_parameter(
            Name = Node_group_full_name
            )
            logger.info("Successfully deleted parameter")
        else:
            logger.warning('Not supported action')

    except Exception as e:
        logger.error('Something went wrong: ' + str(e))
        return False

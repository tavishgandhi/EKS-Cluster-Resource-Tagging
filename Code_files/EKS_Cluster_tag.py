from __future__ import print_function
import json
import boto3
import logging
import time
import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    #logger.info('Event: ' + str(event)),
    #print('Received event: ' + json.dumps(event, indent=2)),
    ids = []
    try:
        region = event['region']
        detail = event['detail']
        eventname = detail['eventName']
        arn = detail['userIdentity']['arn']
        principal = detail['userIdentity']['principalId']
        userType = detail['userIdentity']['type']


        if userType == 'IAMUser':
            user = detail['userIdentity']['userName']
        else:
            user = principal.split('/')[1]

        logger.info('User: ' + str(user))
        logger.info('principalId: ' + str(principal))
        logger.info('region: ' + str(region))
        logger.info('eventName: ' + str(eventname))

        if not detail['responseElements']:
            logger.warning('No responseElements found')
            if event['errorCode']:
                logger.error('errorCode: ' + event['errorCode'])
            if event['errorMessage']:
                logger.error('errorMessage: ' + event['errorMessage'])
                return False
        else:
            eksclustername = detail['responseElements']['cluster']['name']
            eksclusterarn = detail['responseElements']['cluster']['arn']

        logger.info('eksclustername: ' + str(eksclustername))
        logger.info('eksclusterarn: ' + str(eksclusterarn))

        client = boto3.client('eks')
        ssm = boto3.client('ssm')

        if eventname == "CreateCluster":
            response = client.tag_resource(resourceArn=eksclusterarn,tags={'Owner': user})
            parameter_name = "/NodeGroupNames/" + eksclustername + "/SampleKey"
            value = "SampleValue"
            response = ssm.put_parameter(
                Name=parameter_name,
                Description='Creating top hierarchy for node group names',
                Value=value,
                Type='String'
            )
        elif eventname == "DeleteCluster":
            parameter_name  = "/NodeGroupNames/" + eksclustername + "/SampleKey"
            response = ssm.delete_parameter(
            Name = parameter_name
            )
            logger.info("Successfully deleted parameter")
        else:
            logger.warning('Not supported action')


    except Exception as e:
        logger.error('Something went wrong: ' + str(e))
        return False

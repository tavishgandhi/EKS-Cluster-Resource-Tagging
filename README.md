# EKS-Cluster-Resource-Tagging
Now we all want to ensure that our resources are appropriately tagged especially when the AWS account is being used by number of people from the organization. You must have 
put in place a price limit also for how much is allowed to spend by an individual user and the basis for it is exclusively resources being tagged by the Owners name.  

Now the automation is simple when a user provision resource, we can just find who provisioned the resources from CloudTrail as the information is captured and subsequently 
invoking a Cloudwatch event to instruct lambda to extract the useful information from the event and tag the concerned resource.

But, here is it when it gets tricky - What if the resources provisioned are provisioned by a role assumed by a service instructed by another service. How do you find which user 
was the one who instructed the very first service to do the same. 
When you provision an EKS Cluster and Node Groups, the roles associated with them give them permission to launch the worker nodes, create autoscaling groups, launch templates,
subnets, security groups, etc.

The code in repository deals with such kind of challenge and appropriately tag all the resources associated with a particular Node group and Cluster.
It also deploys the code to all the regions thus ensuring IAC with no errors.


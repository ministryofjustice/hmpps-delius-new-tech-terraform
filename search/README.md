# New Tech ElasticSearch Cluster
Terraform code to stand up an AWS managed ES cluster inside a VPC.

## Limitations of VPC Cluster
See https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-vpc.html#es-vpc-limitations

## High Availability
Sepcifying a number of data node instances `var.search_conf["es_instance_count"]` will enable zone awareness (multi AZ). The number of required AZs and subnets will be calculated automatically based on the instance count.

## Authentication

A shared user account is configured in Cognito. As Terraform does not support Cognito Users yet, the user will be created manually. An SSM Parameter is created within this codebase, but as the user is forced to change the password on first login, the value of the ssm parameter wll be set manually in a one time operation at deployment.

**Setup Steps:**
- Log into Cognito in the target ENvironment and manage the NewTech Search User Pool
- Create New User and set temp password which matches the password policy
- Log into Kibana via the VPC Endpoint (see below) and change password when prompted
- Store new password in the SSM Parameter created in this code base

## Access
The ES cluster can be accessed either from allowed services, such as New Tech Front End, or via the Bastion servers. Access is predicated on having ssh access to the Bastion serving the target environment.

To interact with the service, a user can either use tools such as curl direct from a Bastion session, or tunnel through, which would be more useful for Kibana access.

For Kibana access via a browser:
- Create a socks tunnel via the bastion, e.g.
`ssh -D 8157 -f -C -q -N user@bastion`
- Follow *Configure Socks Proxy* setup instructions: https://aws.amazon.com/premiumsupport/knowledge-center/kibana-outside-vpc-ssh-elasticsearch/ 
- Browse to https://_VPC-ENDPOINT_/_plugin/kibana
- SIgn in as webops user


The ES endpoints are available from terraform outputs as follows:
- ES:  `newtech_search_config["endpoint"]` 
- Kibana:  `newtech_search_config["kibana_endpoint"]` 

All traffic is served via HTTPS on TCP/443.
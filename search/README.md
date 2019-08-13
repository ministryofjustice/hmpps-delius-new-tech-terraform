# New Tech ElasticSearch Cluster
Terraform code to stand up an AWS managed ES cluster inside a VPC.

## Limitations of VPC Cluster
See https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-vpc.html#es-vpc-limitations

## High Availability
Sepcifying a number of data node instances `var.search_conf["es_instance_count"]` will enable zone awareness (multi AZ). The number of required AZs and subnets will be calculated automatically based on the instance count.

## Access
The ES cluster can be accessed either from allowed services, such as New Tech Front End, or via the Bastion servers. Access is predicated on having ssh access to the Bastion serving the target environment.

To interact with the service, a user can either use tools such as curl direct from a Bastion session, or tunnel through, which would be more useful for Kibana access.

The ES endpoints are available from terraform outputs as follows:
- ES:  `newtech_search_config["endpoint"]` 
- Kibana:  `newtech_search_config["kibana_endpoint"]` 

All traffic is served via HTTPS on TCP/443.
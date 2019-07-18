# Case Notes Poll Push Service
Deploys an ECS Task definition and service to the shared ECS cluster.
The service is effectively a long running batch process that polls Nomis every X seconds for case note updates. These are then pulled and stored in a dedicated mongodb store, before being pushed into NDelius via the interface API.

## IAM
The task runs under 2 IAM roles:

- Execution role = Executes the task, so needs to be able to pull the image, get SSM Parameters for secret env configs
- Task role = This is the role, with any policies, that apply to the running container

The shared ECS cluster is configured with the *ECS_AWSVPC_BLOCK_IMDS=true* config value to prevent tasks from reaching the host level metadata service under the host's own ec2 instance profile.

## Env Configs
Case notes specific environment variables are set out in the casenotes_conf variable which is a map.
One or more of the KV pairs can be overridden in the env_configs/{ENVIRONMENT}/sub-projects/new-tech.tfvars file as necessary
Where no override is provided, the default value will be used.
[{
    "name": "${container_name}",
    "image": "${image_url}:${image_version}",
    "essential": true,
    "interactive": true,
    "healthCheck": {
        "command": [ "CMD-SHELL", "ps -ef | grep -v grep | grep offenderPollPush.jar || exit 1" ],
        "interval": 60,
        "retries": 2,
        "startPeriod": 60,
        "timeout": 5
    },
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${log_group_name}",
            "awslogs-region": "${region}",
            "awslogs-stream-prefix": "ecs-${container_name}"
        }
    },
    "environment": [
        {
          "name": "DEBUG_LOG",
          "value": "${env_debug_log}"
        },
        {
          "name": "INDEX_ALL_OFFENDERS",
          "value": "${env_index_all_offenders}"
        },
        {
          "name": "INGESTION_PIPELINE",
          "value": "${env_ingestion_pipeline}"
        },
        {
          "name": "DELIUS_API_BASE_URL",
          "value": "${env_delius_api_base_url}"
        },
        {
          "name": "DELIUS_API_USERNAME",
          "value": "${env_delius_api_username}"
        },
        {
          "name": "ELASTIC_SEARCH_SCHEME",
          "value": "${env_elastic_search_scheme}"
        },
        {
          "name": "ELASTIC_SEARCH_HOST",
          "value": "${env_elastic_search_host}"
        },
        {
          "name": "ELASTIC_SEARCH_CLUSTER",
          "value": "${env_elastic_search_cluster}"
        },     
        {
          "name": "ELASTIC_SEARCH_PORT",
          "value": "${env_elastic_search_port}"
        },
        {
          "name": "ELASTIC_SEARCH_AWS_SIGNREQUESTS",
          "value": "${env_elastic_search_aws_signrequests}"
        },
        {
          "name": "ELASTIC_SEARCH_AWS_REGION",
          "value": "${region}"
        },
        {
          "name": "ELASTIC_SEARCH_AWS_SERVICENAME",
          "value": "${env_elastic_search_aws_servicename}"
        },
        {
          "name": "ALL_PULL_PAGE_SIZE",
          "value": "${env_all_pull_page_size}"
        },
        {
          "name": "PROCESS_PAGE_SIZE",
          "value": "${env_process_page_size}"
        },
        {
          "name": "POLL_SECONDS",
          "value": "${env_poll_seconds}"
        }
      ],
    "secrets": [],
    "volumesFrom": [],
    "mountPoints": [],
    "portMappings": [],
    "cpu": 0
}]
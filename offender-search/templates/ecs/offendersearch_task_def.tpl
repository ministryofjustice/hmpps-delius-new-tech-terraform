[{
    "name": "${container_name}",
    "image": "${image_url}:${image_version}",
    "essential": true,
    "interactive": true,
    "healthCheck": {
        "command": [ "CMD-SHELL", "curl -s http://localhost:${service_port}/health/ping | jq -r -e '.|select(.status==\"OK\")' || exit 1" ],
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
          "name": "SPRING_PROFILES_ACTIVE",
          "value": "elasticsearch"
        },
        {
            "name": "JWT_PUBLIC_KEY",
            "value": "${env_jwt_public_key}"
        },
        {
          "name": "ELASTIC_SEARCH_HOST",
          "value": "${env_elastic_search_host}"
        },
        {
          "name": "ELASTIC_SEARCH_PORT",
          "value": "${env_elastic_search_port}"
        },
        {
          "name": "ELASTIC_SEARCH_SCHEME",
          "value": "${env_elastic_search_scheme}"
        },
        {
          "name": "ELASTIC_SEARCH_AWS_SIGNREQUESTS",
          "value": "${env_elastic_search_sign_requests}"
        },
        {
          "name": "ELASTIC_SEARCH_AWS_REGION",
          "value": "${region}"
        }
      ],
    "secrets": [
        {
            "name": "APPINSIGHTS_INSTRUMENTATIONKEY",
            "valueFrom": "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/newtech/offenderapi/appinsights_key"
        }
    ],
    "volumesFrom": [],
    "mountPoints": [],
    "portMappings": [
        { 
               "containerPort": ${service_port},
               "hostPort": ${service_port},
               "protocol": "tcp"
            }
    ],
    "cpu": 0
}]
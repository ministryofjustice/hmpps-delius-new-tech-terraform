[{
    "name": "${container_name}",
    "image": "${image_url}:${image_version}",
    "essential": true,
    "interactive": true,
    "healthCheck": {
        "command": [ "CMD-SHELL", "curl -s http://localhost:8080/info" ],
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
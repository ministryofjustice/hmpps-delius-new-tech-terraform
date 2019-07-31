[{
    "name": "${container_name}",
    "image": "${image_url}:${image_version}",
    "essential": true,
    "interactive": true,
    "healthCheck": {
        "command": [ "CMD-SHELL", "curl -s http://localhost:8080/healthcheck | jq -r -e '.|select(.status==\"OK\")' || exit 1" ],
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
            "name": "PORT",
            "value": "${env_service_port}"
        }
      ],
    "secrets": [],
    "volumesFrom": [],
    "mountPoints": [],
    "portMappings": [
        { 
               "containerPort": ${env_service_port},
               "hostPort": ${env_service_port},
               "protocol": "tcp"
            }
    ],
    "cpu": 0
}]
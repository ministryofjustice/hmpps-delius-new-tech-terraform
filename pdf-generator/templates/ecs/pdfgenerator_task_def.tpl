[{
    "name": "${container_name}",
    "image": "${image_url}:${image_version}",
    "essential": true,
    "interactive": true,
    "healthCheck": {
        "command": [ "/bin/sh", "$(curl http://localhost:8080/healthcheck | jq -r -e '.|select(.status==\"OK\")|length') || exit 1" ],
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
        }
      ],
    "secrets": [],
    "volumesFrom": [],
    "mountPoints": [],
    "portMappings": [],
    "cpu": 0
}]
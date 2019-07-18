[{
    "name": "${container_name}",
    "image": "${image_url}:${image_version}",
    "essential": true,
    "memory": ${memory},
    "healthCheck": {
        "command": [ "/bin/sh", "$(ps -ef | grep -v grep | grep -c pollPush.jar) || exit 1" ],
        "interval": 60,
        "retries": 2,
        "startPeriod": 60
    }
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-create-group": "true",
            "awslogs-group": "${log_group_name}",
            "awslogs-region": "${region}",
            "awslogs-stream-prefix": "ecs-${container_name}"
        }
    }
}]
[{
    "name": "${container_name}",
    "image": "${image_url}:${image_version}",
    "essential": true,
    "interactive": true,
    "healthCheck": {
        "command": [ "CMD-SHELL", "echo 'db.runCommand(\"ping\").ok' | mongo localhost:27017/test --quiet || exit 1" ],
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
    "portMappings": [ 
            { 
               "containerPort": 27017,
               "hostPort": 27017,
               "protocol": "tcp"
            }
    ],
    "mountPoints": [
        {
            "containerPath": "/data/db",
            "sourceVolume": "${volume_name}"
        }
    ],
    "environment": [],
    "volumesFrom": [],
    "cpu": 0
}]
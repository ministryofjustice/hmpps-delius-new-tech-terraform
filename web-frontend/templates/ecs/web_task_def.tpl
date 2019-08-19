[{
    "name": "${container_name}",
    "image": "${image_url}:${image_version}",
    "essential": true,
    "interactive": true,
    "healthCheck": {
        "command": [ "CMD-SHELL", "curl -s http://localhost:${service_port}/healthcheck | jq -r -e '.|select(.status==\"OK\")' || exit 1" ],
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
          "name": "SOME_ENV",
          "value": ""
        }
      ],
    "secrets": [
        {
            "name": "APPLICATION_SECRET",
            "valueFrom": "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/delius-database/db/delius_pool_password"
        }
    ],
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
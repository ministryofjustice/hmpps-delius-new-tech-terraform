[{
    "name": "${container_name}",
    "image": "${image_url}:${image_version}",
    "essential": true,
    "interactive": true,
    "healthCheck": {
        "command": [ "/bin/sh", "$(ps -ef | grep -v grep | grep -c pollPush.jar) || exit 1" ],
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
          "name": "MONGO_DB_URL",
          "value": "${env_mongo_db_url}"
        },
        {
          "name": "MONGO_DB_NAME",
          "value": "${env_mongo_db_name}"
        },
        {
          "name": "PULL_BASE_URL",
          "value": "${env_pull_base_url}"
        },
        {
          "name": "PULL_NOTE_TYPES",
          "value": "${env_pull_note_types}"
        },
        {
          "name": "PUSH_BASE_URL",
          "value": "${env_push_base_url}"
        },
        {
          "name": "POLL_SECONDS",
          "value": "${env_poll_seconds}"
        },
        {
          "name": "SLACK_SECONDS",
          "value": "${env_slack_seconds}"
        }
      ],
    "secrets": [
        {
            "name": "PUSH_USERNAME",
            "valueFrom": "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/apacheds/apacheds/casenotes_user"
        },
        {
            "name": "PUSH_PASSWORD",
            "valueFrom": "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/apacheds/apacheds/casenotes_password"
        },
        {
            "name": "NOMIS_TOKEN",
            "valueFrom": "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/newtech/casenotes/nomis_token"
        },
        {
            "name": "PRIVATE_KEY",
            "valueFrom": "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/newtech/casenotes/nomis_private_key"
        },
        {
            "name": "PUBLIC_KEY",
            "valueFrom": "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/newtech/casenotes/nomis_public_key"
        }
    ],
    "volumesFrom": [],
    "mountPoints": [],
    "portMappings": [],
    "cpu": 0
}]
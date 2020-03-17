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
          "value": "elasticsearch,stdout"
        },
        {
          "name": "ELASTICSEARCH_HOST",
          "value": "${env_elastic_search_host}"
        },
        {
          "name": "ELASTICSEARCH_PORT",
          "value": "${env_elastic_search_port}"
        },
        {
          "name": "ELASTICSEARCH_SCHEME",
          "value": "${env_elastic_search_scheme}"
        },
        {
          "name": "ELASTICSEARCH_AWS_SIGNREQUESTS",
          "value": "${env_elastic_search_sign_requests}"
        },
        {
          "name": "ELASTICSEARCH_PROVIDER",
          "value": "aws"
        },
        {
          "name": "AWS_REGION",
          "value": "${region}"
        },
        {
           "name": "SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_JWK-SET-URI",
           "value": "${env_oauth2_jwt_jwk_set_uri}"
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
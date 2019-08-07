[{
    "name": "${container_name}",
    "image": "${image_url}:${image_version}",
    "essential": true,
    "interactive": true,
    "healthCheck": {
        "command": [ "CMD-SHELL", "curl -s http://localhost:8080/api/health | jq -r -e '.|select(.status==\"UP\")' || exit 1" ],
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
          "value": "${env_spring_profiles_active}"
        },
        {
            "name": "SPRING_DATASOURCE_URL",
            "value": "jdbc:oracle:thin:@(DESCRIPTION=(LOAD_BALANCE=OFF)(FAILOVER=ON)(CONNECT_TIMEOUT=10)(RETRY_COUNT=3)(ADDRESS_LIST=(ADDRESS=(PROTOCOL=tcp)(HOST=delius-db-1.${env_public_zone})(PORT=1521))(ADDRESS=(PROTOCOL=tcp)(HOST=delius-db-2.${env_public_zone})(PORT=1521))(ADDRESS=(PROTOCOL=tcp)(HOST=delius-db-3.${env_public_zone})(PORT=1521)) )(CONNECT_DATA=(SERVICE_NAME=${env_oracledb_servicename})))"
        },
        {
            "name": "SPRING_DATASOURCE_USERNAME",
            "value": "${env_spring_datasource_username}"
        },
        {
            "name": "SPRING_LDAP_URLS",
            "value": "ldap://${env_ldap_endpoint}:${env_ldap_port}"
        },
        {
            "name": "SPRING_LDAP_USERNAME",
            "value": "${env_spring_ldap_username}"
        },
        {
            "name": "DEBUG",
            "value": "${env_debug}"
        }
      ],
    "secrets": [
        {
            "name": "SPRING_DATASOURCE_PASSWORD",
            "valueFrom": "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/delius-database/db/delius_pool_password"
        },
        {
            "name": "SPRING_LDAP_PASSWORD",
            "valueFrom": "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/apacheds/apacheds/ldap_admin_password"
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
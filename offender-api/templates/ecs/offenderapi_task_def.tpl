[{
    "name": "${container_name}",
    "image": "${image_url}:${image_version}",
    "essential": true,
    "interactive": true,
    "healthCheck": {
        "command": [ "CMD-SHELL", "curl -s http://localhost:8080/health/ping" ],
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
        },
        {
            "name": "ALFRESCO_BASEURL",
            "value": "${env_alfresco_baseurl}"
        },
        {
            "name": "JWT_PUBLIC_KEY",
            "value": "${env_jwt_public_key}"
        },
        {
            "name": "DELIUS_LDAP_USERS_BASE",
            "value": "${env_delius_ldap_users_base}"
        },
        {
            "name": "DELIUS_BASEURL",
            "value": "${env_push_base_url}"
        },
        {
            "name": "FEATURES_NOMS_UPDATE_CUSTODY",
            "value": "${env_features_noms_update_custody}"
        },
        {
            "name": "FEATURES_NOMS_UPDATE_BOOKING_NUMBER",
            "value": "${env_features_noms_update_booking_number}"
        },
        {
            "name": "FEATURES_NOMS_UPDATE_KEYDATES",
            "value": "${env_features_noms_update_keydates}"
        },
        {
            "name": "FEATURES_NOMS_UPDATE_NOMS_NUMBER",
            "value": "${env_features_noms_update_noms_number}"
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
        },
        {
            "name": "APPINSIGHTS_INSTRUMENTATIONKEY",
            "valueFrom": "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/newtech/offenderapi/appinsights_key"
        },
        {
            "name": "DELIUS_USERNAME",
            "valueFrom": "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/apacheds/apacheds/casenotes_user"
        },
        {
            "name": "DELIUS_PASSWORD",
            "valueFrom": "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/apacheds/apacheds/casenotes_password"
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

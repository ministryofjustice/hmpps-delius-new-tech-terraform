[{
    "name": "${container_name}",
    "image": "${image_url}:${image_version}",
    "essential": true,
    "interactive": true,
    "healthCheck": {
      "command": [
        "CMD-SHELL",
        "curl -s http://localhost:${service_port}/newTech/healthcheck | jq -r -e '.|select(.status==\"OK\")' || exit 1"
      ],
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
        "name": "PARAMS_USER_TOKEN_VALID_DURATION",
        "value": "${env_params_user_token_valid_duration}"
      },
      {
        "name": "STORE_PROVIDER",
        "value": "${env_store_provider}"
      },
      {
        "name": "DELIUS_API_BASE_URL",
        "value": "${env_offender_api_endpoint}"
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
      },
      {
        "name": "NOMIS_API_BASE_URL",
        "value": "${env_nomis_api_base_url}"
      },
      {
        "name": "PDF_GENERATOR_URL",
        "value": "${env_pdf_generator_url}"
      },
      {
        "name": "STORE_ALFRESCO_URL",
        "value": "${env_store_alfresco_url}"
      },
      {
        "name": "STORE_ALFRESCO_USER",
        "value": "${env_store_alfresco_user}"
      },
      {
        "name": "PRISONER_API_PROVIDER",
        "value": "${env_prisoner_api_provider}"
      },
      {
        "name": "BASE_PATH",
        "value": "${env_base_path}"
      },
      {
        "name": "LDAP_STRING_FORMAT",
        "value": "${env_ldap_string_format}"
      },
      {
        "name": "FEEDBACK_FORM_URL",
        "value": "${env_feedback_form_url}"
      },
      {
        "name": "FEEDBACK_PAROM1_FORM_URL",
        "value": "${env_feedback_parom1_form_url}"
      },
      {
        "name": "FEEDBACK_SEARCH_FORM_URL",
        "value": "${env_feedback_search_form_url}"
      },
      {
        "name": "FEEDBACK_OFFENDER_SUMMARY_FORM_URL",
        "value": "${env_feedback_offender_summary_form_url}"
      }
    ],
    "secrets": [
      {
        "name": "APPLICATION_SECRET",
        "valueFrom": "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/newtech/web/application_secret"
      },
      {
        "name": "CUSTODY_API_USERNAME",
        "valueFrom": "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/newtech/web/custody_api_username"
      },
      {
        "name": "CUSTODY_API_PASSWORD",
        "valueFrom": "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/newtech/web/custody_api_password"
      },
      {
        "name": "GOOGLE_ANALYTICS_ID",
        "valueFrom": "arn:aws:ssm:${region}:${aws_account_id}:parameter/${environment_name}/${project_name}/monitoring/analytics/google_id"
      }
    ],
    "volumesFrom": [],
    "mountPoints": [],
    "portMappings": [{
       "containerPort": ${service_port},
       "hostPort": ${service_port},
       "protocol": "tcp"
    }],
    "cpu": 0
}]
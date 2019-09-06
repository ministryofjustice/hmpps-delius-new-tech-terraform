def project = [:]
project.config    = 'hmpps-env-configs'
project.newtech     = 'hmpps-delius-new-tech-terraform'

// Parameters required for job
// parameters:
//     choice:
//       name: 'environment_name'
//       description: 'Environment name.'

def prepare_env() {
    sh '''
    #!/usr/env/bin bash
    docker pull mojdigitalstudio/hmpps-terraform-builder:latest
    '''
}

def plan_submodule(config_dir, env_name, git_project_dir, submodule_name) {
    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
        sh """
        #!/usr/env/bin bash
        echo "TF PLAN for ${env_name} | ${submodule_name} - component from git project ${git_project_dir}"
        set +e
        cp -R -n "${config_dir}" "${git_project_dir}/env_configs"
        cd "${git_project_dir}"
        docker run --rm \
            -v `pwd`:/home/tools/data \
            -v ~/.aws:/home/tools/.aws mojdigitalstudio/hmpps-terraform-builder \
            bash -c "\
                source env_configs/${env_name}/${env_name}.properties; \
                cd ${submodule_name}; \
                if [ -d .terraform ]; then rm -rf .terraform; fi; sleep 5; \
                terragrunt init; \
                terragrunt plan > tf.plan.out; \
                exitcode=\\\"\\\$?\\\"; \
                cat tf.plan.out; \
                if [ \\\"\\\$exitcode\\\" == '1' ]; then exit 1; fi; \
                parse-terraform-plan -i tf.plan.out | jq '.changedResources[] | (.action != \\\"update\\\") or (.changedAttributes | to_entries | map(.key != \\\"tags.source-hash\\\") | reduce .[] as \\\$item (false; . or \\\$item))' | jq -e -s 'reduce .[] as \\\$item (false; . or \\\$item) == false'" \
            || exitcode="\$?"; \
            echo "\$exitcode" > plan_ret; \
            if [ "\$exitcode" == '1' ]; then exit 1; else exit 0; fi
        set -e
        """
        return readFile("${git_project_dir}/plan_ret").trim()
    }
}

pipeline {

    agent { label "jenkins_slave" }

    parameters {
        string(name: 'CONFIG_BRANCH', description: 'Target Branch for hmpps-env-configs', defaultValue: 'master')
    }

    stages {

        stage('setup') {
            steps {
                slackSend(message: "Build started on \"${environment_name}\" - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL.replace(':8080','')}|Open>)")

                dir( project.config ) {
                  git url: 'git@github.com:ministryofjustice/' + project.config, branch: env.CONFIG_BRANCH, credentialsId: 'f44bc5f1-30bd-4ab9-ad61-cc32caf1562a'
                }
                dir( project.newtech ) {
                  checkout scm
                }
                prepare_env()
            }
        }
        // delius-test
        stage('New Tech') {
          parallel {
            stage('Plan New Tech Case Notes'){ steps { script {plan_submodule(project.config, environment_name, project.newtech, 'case-notes')}}}
            stage('Plan New Tech PDF Generator'){ steps { script {plan_submodule(project.config, environment_name, project.newtech, 'pdf-generator')}}}
            stage('Plan New Tech Offender API'){ steps { script {plan_submodule(project.config, environment_name, project.newtech, 'offender-api')}}}
            stage('Plan New Tech Search'){ steps { script {plan_submodule(project.config, environment_name, project.newtech, 'search')}}}
            stage('Plan New Tech Offender Poll Push'){ steps { script {plan_submodule(project.config, environment_name, project.newtech, 'offender-pollpush')}}}
            stage('Plan New Tech Web Frontend'){ steps { script {plan_submodule(project.config, environment_name, project.newtech, 'web-frontend')}}}
          }
        }
    }

    post {
        always {
            deleteDir()
        }
        success {
            slackSend(message: "Build completed on \"${environment_name}\" - ${env.JOB_NAME} ${env.BUILD_NUMBER} ", color: 'good')
        }
        failure {
            slackSend(message: "Build failed on \"${environment_name}\" - ${env.JOB_NAME} ${env.BUILD_NUMBER} ", color: 'danger')
        }
    }

}

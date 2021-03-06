def project = [:]
project.config    = 'hmpps-env-configs'
project.newtech     = 'hmpps-delius-new-tech-terraform'

def prepare_env() {
    sh '''
    #!/usr/env/bin bash
    docker pull mojdigitalstudio/hmpps-terraform-builder-0-11-14:latest
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
            -v ~/.aws:/home/tools/.aws mojdigitalstudio/hmpps-terraform-builder-0-11-14 \
            bash -c "\
                source env_configs/${env_name}/${env_name}.properties; \
                cd ${submodule_name}; \
                if [ -d .terraform ]; then rm -rf .terraform; fi; sleep 5; \
                terragrunt init; \
                terragrunt refresh; \
                terragrunt plan -detailed-exitcode --out ${env_name}.plan > tf.plan.out; \
                exitcode=\\\"\\\$?\\\"; \
                echo \\\"\\\$exitcode\\\" > plan_ret; \
                cat tf.plan.out; \
                if [ \\\"\\\$exitcode\\\" == '1' ]; then exit 1; fi; \
                echo \\\"\\\$exitcode\\\" > plan_ret;" \
            || exitcode="\$?"; \
            if [ "\$exitcode" == '1' ]; then exit 1; else exit 0; fi
        set -e
        """
        return readFile("${git_project_dir}/${submodule_name}/plan_ret").trim()
    }
}

def apply_submodule(config_dir, env_name, git_project_dir, submodule_name) {
    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'XTerm']) {
        sh """
        #!/usr/env/bin bash
        echo "TF APPLY for ${env_name} | ${submodule_name} - component from git project ${git_project_dir}"
        set +e
        cp -R -n "${config_dir}" "${git_project_dir}/env_configs"
        cd "${git_project_dir}"
        docker run --rm \
          -v `pwd`:/home/tools/data \
          -v ~/.aws:/home/tools/.aws mojdigitalstudio/hmpps-terraform-builder-0-11-14 \
          bash -c " \
              source env_configs/${env_name}/${env_name}.properties; \
              cd ${submodule_name}; \
              terragrunt apply ${env_name}.plan; \
              tgexitcode=\\\$?; \
              echo \\\"TG exited with code \\\$tgexitcode\\\"; \
              if [ \\\$tgexitcode -ne 0 ]; then \
                exit  \\\$tgexitcode; \
              else \
                exit 0; \
              fi;"; \
        dockerexitcode=\$?; \
        echo "Docker step exited with code \$dockerexitcode"; \
        if [ \$dockerexitcode -ne 0 ]; then exit \$dockerexitcode; else exit 0; fi;
        set -e
        """
    }
}

def confirm() {
    try {
        timeout(time: 15, unit: 'MINUTES') {
            env.Continue = input(
                id: 'Proceed1', message: 'Apply plan?', parameters: [
                    [$class: 'BooleanParameterDefinition', defaultValue: true, description: '', name: 'Apply Terraform']
                ]
            )
        }
    } catch(err) { // timeout reached or input false
        def user = err.getCauses()[0].getUser()
        env.Continue = false
        if('SYSTEM' == user.toString()) { // SYSTEM means timeout.
            echo "Timeout"
            error("Build failed because confirmation timed out")
        } else {
            echo "Aborted by: [${user}]"
        }
    }
}

def do_terraform(config_dir, env_name, git_project, component) {
    plancode = plan_submodule(config_dir, env_name, git_project, component)
    if (plancode == "2") {
        if ("${confirmation}" == "true") {
            confirm()
        } else {
            env.Continue = true
        }
        if (env.Continue == "true") {
            apply_submodule(config_dir, env_name, git_project, component)
        }
    }
    else if (plancode == "3") {
        apply_submodule(config_dir, env_name, git_project, component)
        env.Continue = true
    }
    else {
        env.Continue = true
    }
}

def debug_env() {
    sh '''
    #!/usr/env/bin bash
    pwd
    ls -al
    '''
}

pipeline {

    agent { label "jenkins_agent" }

    parameters {
        string(name: 'CONFIG_BRANCH', description: 'Target Branch for hmpps-env-configs', defaultValue: 'master')
        string(name: 'NEWTECH_BRANCH', description: 'Target Branch for hmpps-delius-new-tech-terraform', defaultValue: 'main')
        booleanParam(name: 'deploy_NTCaseNotes', defaultValue: false, description: 'Deploy New Tech Case Notes?')
        booleanParam(name: 'deploy_NTPDFGenerator', defaultValue: false, description: 'New Tech PDF Generator?')
        booleanParam(name: 'deploy_NTOffenderAPI', defaultValue: false, description: 'New Tech Offender API?')
        booleanParam(name: 'deploy_NTElasticSearch', defaultValue: false, description: 'New Tech ElasticSearch?')
        booleanParam(name: 'deploy_NTDOffenderSearch', defaultValue: false, description: 'New Tech Offender Search Service?')
        booleanParam(name: 'deploy_NTOffenderPollPush', defaultValue: false, description: 'New Tech Offender Poll Push?')
        booleanParam(name: 'deploy_NTWebFrontend', defaultValue: false, description: 'New Tech Web Frontend?')
        booleanParam(name: 'deploy_NTDashboards', defaultValue: false, description: 'New Tech Dashboards?')
    }

    stages {

        stage('setup') {
            steps {
                slackSend(message: "Build started on \"${environment_name}\" - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL.replace(':8080','')}|Open>)")

                dir( project.config ) {
                  git url: 'git@github.com:ministryofjustice/' + project.config, branch: env.CONFIG_BRANCH, credentialsId: 'f44bc5f1-30bd-4ab9-ad61-cc32caf1562a'
                }
                dir( project.newtech ) {
                  git url: 'git@github.com:ministryofjustice/' + project.newtech, branch: env.NEWTECH_BRANCH, credentialsId: 'f44bc5f1-30bd-4ab9-ad61-cc32caf1562a'
                }
                prepare_env()
            }
        }

        stage('New Tech Case Notes') {
          when { expression { return params.deploy_NTCaseNotes } }
          steps {
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
              do_terraform(project.config, environment_name, project.newtech, 'case-notes')
            }
          }
        }

        stage('New Tech PDF Generator') {
          when { expression { return params.deploy_NTPDFGenerator } }
          steps {
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
              do_terraform(project.config, environment_name, project.newtech, 'pdf-generator')
            }
          }
        }

        stage('New Tech Offender API') {
          when { expression { return params.deploy_NTOffenderAPI } }
          steps {
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
              do_terraform(project.config, environment_name, project.newtech, 'offender-api')
            }
          }
        }

        stage('New Tech ElasticSearch') {
          when { expression { return params.deploy_NTElasticSearch } }
          steps {
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
              do_terraform(project.config, environment_name, project.newtech, 'search')
            }
          }
        }

        stage('New Tech Offender Search Service') {
          when { expression { return params.deploy_NTDOffenderSearch } }
          steps {
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
              do_terraform(project.config, environment_name, project.newtech, 'offender-search')
            }
          }
        }

        stage('New Tech Offender Poll Push') {
          when { expression { return params.deploy_NTOffenderPollPush } }
          steps {
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
              do_terraform(project.config, environment_name, project.newtech, 'offender-pollpush')
            }
          }
        }

        stage('New Tech Web Frontend') {
          when { expression { return params.deploy_NTWebFrontend } }
          steps {
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
              do_terraform(project.config, environment_name, project.newtech, 'web-frontend')
            }
          }
        }

        stage('New Tech Dashboards') {
          when { expression { return params.deploy_NTDashboards } }
          steps {
            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
              do_terraform(project.config, environment_name, project.newtech, 'dashboards')
            }
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

pipeline {
    agent any
    triggers {
        pollSCM 'H/5 * * * *'
    }
    environment {
        VERSION = "1.0.${BUILD_NUMBER}"
    }
    stages {
        stage('Build WAR') {
            steps {
                sh "mvn install -Dversion=$VERSION"
            }
        }
        stage('Build Docker Image') {
            steps {
                sh "docker build -t petclinic:$VERSION"
            }
        }
        stage('Publish to ECR') {
            steps {
                sh '''
                    $(aws ecr get-login --no-include-email --region us-east-1)
                    docker tag petclinic:$version xxxxxxxxxxxx.dkr.ecr.us-east-1.amazonaws.com/petclinic:$VERSION
                    docker push xxxxxxxxxxxx.dkr.ecr.us-east-1.amazonaws.com/petclinic:$VERSION
                '''
            }
        }
        stage('Update ECS Task Definition') {
            steps {
                sh "ansible-playbook devops/ansible/playbooks/ecs-petclinic-cicd.yml -e \\\"image=xxxxxxxxxxxx.dkr.ecr.us-east-1.amazonaws.com/petclinic:$VERSION\\\""
            }
        }
    }
}
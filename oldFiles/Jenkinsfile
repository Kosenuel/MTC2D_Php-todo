pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = "docker.io"
        DOCKER_IMAGE = "emmanuelokose/php-todo-app"
    }

    stages {
        stage("Initial cleanup") {
            steps {
                dir ("${WORKSPACE}") {
                    deleteDir()
                }
            }
        }

        stage("Checkout") {
            steps {
                checkout scm
            }
        }

        stage ("Build Docker Image") {
            steps {
                script {
                    // Build docker image
                    def branchName = env.BRANCH_NAME
                    env.TAG_NAME = branchName == 'main' ? 'latest' : "${branchName}-0.0.${env.BUILD_NUMBER}"

                    sh """
                        docker build -t ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${env.TAG_NAME} .
                        """
                }
            }
        }

        stage ("Push Docker Image") {
            steps {
                script {
                    // Push docker image to registry using Jenkins credentials
                    withCredentials([usernamePassword(credentialsId: 'docker-credentials', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sh """
                            echo ${PASSWORD} | docker login -u ${USERNAME} --password-stdin ${DOCKER_REGISTRY}
                            docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${env.TAG_NAME}
                            """
                    }
                }
            }
        }

        stage ("Cleanup Docker Images") {
            steps {
                script {
                    // Cleanup docker images
                    sh """
                        docker rmi ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${env.TAG_NAME} || true 
                        """
                }
            }
        }
    }
}
pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = "docker.io"
        DOCKER_IMAGE = "emmanuelokose/php-todo-app"
        COMPOSE_FILE = "php-todo.yaml"
    }

    parameters {
        string (name: "BRANCH_NAME", defaultValue: "main", description: "Branch name to build on")
    }

    stages {
        stage("Initial cleanup") {
            steps {
                dir ("${WORKSPACE}") {
                    deleteDir()
                }
            }
        }

        stage("Checkout Source Code") {
            steps {
                script {
                    // Checkout source code
                    checkout ([
                        $class: 'GitSCM',
                        branches: [[name: "${params.BRANCH_NAME}"]],
                        userRemoteConfigs: [[url: "https://github.com/Kosenuel/MTC2D_Php-todo.git"]]
                        extensions: [[$class: 'CloneOption', depth: 1]]
                    ])
                }
            }
        }

        stage ("Build Docker Image") {
            steps {
                script {
                    // Build docker image
                    def branchName = params.BRANCH_NAME
                    env.TAG_NAME = branchName == 'main' ? 'latest' : "${branchName}-0.0.${env.BUILD_NUMBER}"

                    sh """
                        docker-compose -f ${COMPOSE_FILE} build
                        """
                }
            }
        }

        stage ("Run Docker Compose (Startup Image for Availability Test)") {
            steps {
                script {
                    // Startup the docker container using the compose file
                    sh """
                        docker-compose -f ${COMPOSE_FILE} up -d
                        """
                }
            }
        }

        stage ("Test the Application - Availability Test") {
            steps {
                script {
                    def response
                    retry(5) {
                        sleep(time: 30, unit: 'SECONDS')
                        response = sh(script: "curl -s -o /dev/null -w '%{http_code}' http://localhost:8090", returnStdout: true).trim()
                        echo "HTTP Status Code is: ${response}"
                        if (response != "500") {
                            error "Application is not available. error code: ${response}"
                        } else {
                            echo "Application is very much alive and healthy!"
                        }
                    }
                }
            }
        }

        stage ("Tag and Push Docker Image to Registry") {
            steps {
                script {
                    // Tag the Docker image with the Docker Registry's name and push it to the registry
                    withCredentials([usernamePassword(credentialsId: 'docker-credentials', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sh """
                            echo ${PASSWORD} | docker login -u ${USERNAME} --password-stdin ${DOCKER_REGISTRY}
                            docker tag mtc2d_php-todo_main-app ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${env.TAG_NAME}
                            docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${env.TAG_NAME}
                        """
                    }
                }
            }
        }

        stage ("Stop and Remove the Docker Containers") {
            steps {
                script {
                    // Stop the containers spun up using docker compose
                    sh " docker-compose -f ${COMPOSE_FILE} down"

                    // Remove all containers (including stopped ones)
                    echo 'Removing all Docker containers'
                    sh " docker ps -a -q | xargs -r docker rm "
                }
            }
        }
    }

    // Post Build Actions
    post {
        always {
            script {
                // Logout from Docker
                sh "docker logout"
            }
        }
    }
}

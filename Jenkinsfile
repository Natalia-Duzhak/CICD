pipeline {
    agent any
    environment {
        registry = "nataia/dotnetwebapp"
        img = "${registry}:${env.BUILD_ID}"  // Використовуємо змінну для образу з унікальним тегом
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'dotnetwebapp', url: 'https://github.com/Natalia-Duzhak/CICD.git'
                sh 'ls -la'
            }
        }

        stage('Stop Running Container') {
            steps {
                // Зупиняємо та видаляємо старий контейнер, якщо він існує
                sh returnStatus: true, script: 'docker stop $(docker ps -a | grep ${JOB_NAME} | awk \'{print $1}\')'
                sh returnStatus: true, script: 'docker rmi $(docker images | grep ${registry} | awk \'{print $3}\') --force'
                sh returnStatus: true, script: 'docker rm ${JOB_NAME}'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Створюємо Docker образ
                    sh "docker build -t ${img} ."
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'SonarQube Scanner'
                    withSonarQubeEnv('sonarqube') {
                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                            -Dsonar.projectKey=dotnetwebapp \
                            -Dsonar.sources=. \
                            -Dsonar.host.url=http://localhost:9000 \
                            -Dsonar.login=sqp_99f9a525748b0db44a246e1bb3f64c69b50caca3
                        """
                    }
                }
            }
        }

        stage('Docker Image Creation') {
            steps {
                script {
                    // Створюємо образ для додатка
                    sh "docker build -t ${img} ."
                    // Створюємо додатковий образ з nginx
                    sh "docker build -t ${registry}-with-nginx -f Dockerfile ."
                }
            }
        }

        stage('Docker Container Deployment') {
            steps {
                // Запускаємо контейнер
                sh returnStdout: true, script: "docker run --rm -d --name ${JOB_NAME} -p 8081:5000 ${img}"
            }
        }

        stage('Push Image to DockerHub') {
            steps {
                script {
                    // Логін в DockerHub
                    sh "docker login -u 'nataia' -p '12.07.2003' docker.io"
                    // Тегуємо образ
                    sh "docker tag ${img} ${registry}"
                    // Пушимо образ на DockerHub
                    sh "docker push ${registry}"
                }
            }
        }
    }
}

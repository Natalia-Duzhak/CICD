pipeline {
   agent any
	environment {
		registry = "nataia/dotnetwebapp"
		img = "$registry" + ":${env.BUILD_ID}"
		
    }	

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'dotnetwebapp', url: 'https://github.com/kss7/CICDJenkins.git'
                sh 'ls -la'
            }
        }
		stage('Stop Running Container') {
			steps{
					sh returnStatus: true, script: 'docker stop $(docker ps -a | grep ${JOB_NAME} | awk \'{print $1}\')'
					sh returnStatus: true, script: 'docker rmi $(docker images | grep ${registry} | awk \'{print $3}\') --force' 
					sh returnStatus: true, script: 'docker rm ${JOB_NAME}'
				}	
		}
        stage('Build Docker Image') {
            steps {
				script {
					sh "docker build -t dotnet-web-app ."
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
                    sh "docker build -t dotnet-web-app ."
                    sh "docker build -t dotnet-web-app-with-nginx -f Dockerfile ."
                }
            }
        }
		stage('Docker Container Deploymen') {
			steps{
				sh returnStdout: true, script: "docker run --rm -d --name ${JOB_NAME} -p 8081:5000 dotnet-web-app ."
			}
		}
		stage('Push Image to DockerHub') {
            steps {
				script {
                    sh "docker login -u 'nataia' -p '12.07.2003' docker.io"
					sh "docker tag dotnet-web-app nataia/dotnetwebapp"
					sh "docker push nataia/dotnetwebapp"
						}
                }
            }	
    }
}

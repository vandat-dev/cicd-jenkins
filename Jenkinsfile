pipeline {
    agent any

    environment {
        // Cấu hình thông tin server đích
        SERVER_IP = '100.86.59.89'
        SERVER_USER = 'dat'
        PROJECT_FOLDER = '/home/dat/my-fastapi-app'

        // ID các bí mật lưu trong Jenkins
        SSH_CRED_ID = 'ssh-server-100'
        ENV_FILE_ID = 'prod-env-file'
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs() // Dọn dẹp nhà cửa trước khi làm
            }
        }

        stage('Prepare Secrets') {
            steps {
                // Lấy file .env từ Jenkins Credentials
                withCredentials([file(credentialsId: ENV_FILE_ID, variable: 'MY_ENV')]) {
                    sh 'cp $MY_ENV .env'
                }
            }
        }

        stage('Deploy to Server') {
            steps {
                // Sử dụng SSH Key để kết nối
                sshagent([SSH_CRED_ID]) {
                    // 1. Tạo thư mục trên server (nếu chưa có)
                    sh "ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} 'mkdir -p ${PROJECT_FOLDER}'"

                    // 2. Copy các file cần thiết sang server
                    sh "scp -o StrictHostKeyChecking=no docker-compose.yaml Dockerfile .env requirements.txt ${SERVER_USER}@${SERVER_IP}:${PROJECT_FOLDER}/"
                    sh "scp -o StrictHostKeyChecking=no -r * ${SERVER_USER}@${SERVER_IP}:${PROJECT_FOLDER}/"

                    // 3. SSH vào server và chạy lệnh Docker Compose
                    sh """
                        ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} '
                            cd ${PROJECT_FOLDER}
                            docker compose up -d --build --remove-orphans
                            docker image prune -f
                        '
                    """
                }
            }
        }
    }
}
pipeline {
    agent any

    environment {
        SERVER_IP = '100.68.24.84'
        SERVER_USER = 'dat'
        PROJECT_FOLDER = '/opt/my-project'
    }

    stages {
        // Giai đoạn 0: Dọn dẹp sạch sẽ trước khi làm
        stage('Clean Workspace') {
            steps {
                // Lệnh này xóa sạch thư mục làm việc để tránh lỗi quyền hoặc file rác
                cleanWs()
            }
        }

        // Giai đoạn 1: Code tự về (Do Jenkins tự làm sau khi clean)

        // Giai đoạn 2: Chuẩn bị file Env
        stage('Prepare Secrets') {
            steps {
                withCredentials([file(credentialsId: 'prod-env-file', variable: 'MY_ENV')]) {
                    // Bây giờ quyền đã sạch, lệnh này sẽ chạy ngon
                    sh 'cp $MY_ENV .env'
                }
            }
        }

        // Giai đoạn 3: Deploy sang Server 100.x
        stage('Deploy to Server') {
            steps {
                sshagent(['ssh-server-company']) {
                    // 1. Tạo thư mục
                    sh "ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} 'mkdir -p ${PROJECT_FOLDER}'"

                    // 2. Copy file
                    sh "scp -o StrictHostKeyChecking=no docker-compose.yaml Dockerfile .env requirements.txt ${SERVER_USER}@${SERVER_IP}:${PROJECT_FOLDER}/"
                    sh "scp -o StrictHostKeyChecking=no -r * ${SERVER_USER}@${SERVER_IP}:${PROJECT_FOLDER}/"

                    // 3. Chạy Docker Compose
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
pipeline {
    agent any

    environment {
        SERVER_IP = '100.86.59.89'
        SERVER_USER = 'dat'
        PROJECT_FOLDER = '/home/dat/my-fastapi-app'
        SSH_CRED_ID = 'ssh-server-100'
        ENV_FILE_ID = 'prod-env-file'
    }

    stages {
        // GỘP BƯỚC DỌN DẸP VÀ LẤY CODE LẠI LÀM MỘT
        stage('Setup Workspace') {
            steps {
                // 1. Xóa sạch rác cũ
                cleanWs()

                // 2. QUAN TRỌNG: Tải code từ Azure về lại ngay sau khi xóa
                checkout scm
            }
        }

        stage('Prepare Secrets') {
            steps {
                withCredentials([file(credentialsId: ENV_FILE_ID, variable: 'MY_ENV')]) {
                    sh 'cp $MY_ENV .env'
                }
            }
        }

        stage('Deploy to Server') {
            steps {
                sshagent([SSH_CRED_ID]) {
                    // Tạo thư mục
                    sh "ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} 'mkdir -p ${PROJECT_FOLDER}'"

                    // ===> THÊM DÒNG NÀY: Xóa file .env cũ đi trước khi copy <===
                    // (Thêm -f để nếu file không tồn tại cũng không báo lỗi)
                    sh "ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} 'rm -f ${PROJECT_FOLDER}/.env'"

                    // for coppy all files in workspace to server
                    // Copy file (Giờ chắc chắn sẽ tìm thấy vì đã checkout lại ở trên)
//                     sh "scp -o StrictHostKeyChecking=no docker-compose.yaml Dockerfile .env requirements.txt ${SERVER_USER}@${SERVER_IP}:${PROJECT_FOLDER}/"

                    // Copy toàn bộ code src
//                     sh "scp -o StrictHostKeyChecking=no -r * ${SERVER_USER}@${SERVER_IP}:${PROJECT_FOLDER}/"

                    // 2. Copy 2 file sang: docker-compose.yaml và .env
                    // (Lưu ý: KHÔNG COPY Dockerfile hay thư mục code nữa. Tại vì đã xây dựng image ngay trên server rồi)
                    sh "scp -o StrictHostKeyChecking=no docker-compose.yaml .env ${SERVER_USER}@${SERVER_IP}:${PROJECT_FOLDER}/"

                    // Chạy
                    sh """
                        ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} '
                            cd ${PROJECT_FOLDER}

                            # Tải ảnh mới nhất từ Docker Hub về
                            docker compose pull

                            # Tái tạo container (Nó tự biết dùng ảnh mới)
                            docker compose up -d --remove-orphans

                            # Dọn dẹp ảnh cũ cho sạch ổ cứng
                            docker image prune -f
                        '
                    """
                }
            }
        }
    }
}
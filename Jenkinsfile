stage('Deploy to Server') {
            steps {
                sshagent([SSH_CRED_ID]) {
                    // 1. Tạo thư mục
                    sh "ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} 'mkdir -p ${PROJECT_FOLDER}'"

                    // ===> THÊM DÒNG NÀY: Xóa file .env cũ đi trước khi copy <===
                    // (Thêm -f để nếu file không tồn tại cũng không báo lỗi)
                    sh "ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} 'rm -f ${PROJECT_FOLDER}/.env'"

                    // 2. Copy file (Giờ thì copy thoải mái vì file cũ bay rồi)
                    sh "scp -o StrictHostKeyChecking=no docker-compose.yaml Dockerfile .env requirements.txt ${SERVER_USER}@${SERVER_IP}:${PROJECT_FOLDER}/"

                    // ... (Các lệnh sau giữ nguyên) ...
                    sh "scp -o StrictHostKeyChecking=no -r * ${SERVER_USER}@${SERVER_IP}:${PROJECT_FOLDER}/"

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
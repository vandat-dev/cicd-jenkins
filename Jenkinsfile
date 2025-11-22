pipeline {
    agent any

    environment {
        // Thông tin Server đích
        SERVER_IP = '100.68.24.84'
        SERVER_USER = 'dat' // Thay bằng user thật của server em (vd: ubuntu)
        PROJECT_FOLDER = '/opt/my-project' // Thư mục sẽ để code trên server
    }

    stages {
        // Giai đoạn 1: Jenkins lấy code từ Azure (Tự động nhờ cấu hình Job)

        // Giai đoạn 2: Chuẩn bị file Env
        stage('Prepare Secrets') {
            steps {
                // Lấy file env từ kho mật của Jenkins ra đổi tên thành .env
                withCredentials([file(credentialsId: 'prod-env-file', variable: 'MY_ENV')]) {
                    // Copy file env vào thư mục làm việc hiện tại của Jenkins
                    // Trên Windows dùng lệnh: bat 'copy %MY_ENV% .env'
                    // Trên Linux/Mac/Docker dùng lệnh:
                    sh 'cp $MY_ENV .env'
                }
            }
        }

        // Giai đoạn 3: Deploy sang Server 100.x
        stage('Deploy to Server') {
            steps {
                sshagent(['ssh-server-company']) {
                    // 1. Tạo thư mục trên server nếu chưa có
                    sh "ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} 'mkdir -p ${PROJECT_FOLDER}'"

                    // 2. Copy file docker-compose, Dockerfile và .env sang server
                    // (Lưu ý: Copy đè lên file cũ)
                    sh "scp -o StrictHostKeyChecking=no docker-compose.yaml Dockerfile .env requirements.txt ${SERVER_USER}@${SERVER_IP}:${PROJECT_FOLDER}/"

                    // Copy cả folder code src nếu cần (nhưng ở đây ta copy . là đủ)
                    sh "scp -o StrictHostKeyChecking=no -r * ${SERVER_USER}@${SERVER_IP}:${PROJECT_FOLDER}/"

                    // 3. Chạy lệnh Docker Compose trên server đích
                    sh """
                        ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} '
                            cd ${PROJECT_FOLDER}

                            # Pull image python mới nhất (nếu cần) và Build lại
                            # Lệnh này sẽ tự stop container cũ và chạy cái mới
                            docker compose up -d --build --remove-orphans

                            # Dọn dẹp rác (optional)
                            docker image prune -f
                        '
                    """
                }
            }
        }
    }
}
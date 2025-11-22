# Kết nối Jenkins với Azure Repos

Vì code của bạn nằm trên **Azure Repos** và Jenkins (có thể) đang chạy local, đây là cách thiết lập để Jenkins tự động lấy code về và chạy CI/CD.

## 1. Lấy thông tin từ Azure DevOps
1.  Vào project của bạn trên Azure DevOps.
2.  Vào **Repos** -> **Files**.
3.  Nhấn nút **Clone** (góc trên bên phải).
4.  Copy **HTTPS URL**.

## 2. Tạo Mật khẩu ứng dụng (Personal Access Token - PAT)
Để Jenkins đăng nhập được vào Azure, bạn không nên dùng mật khẩu chính, hãy dùng PAT:
1.  Trên Azure DevOps, bấm vào icon **User Settings** (hình người có bánh răng, góc trên phải) -> **Personal Access Tokens**.
2.  **+ New Token**.
3.  **Name**: `jenkins-access`.
4.  **Organization**: Chọn tổ chức của bạn.
5.  **Scopes**: Chọn **Custom defined** -> Tìm phần **Code** -> Tích vào **Read**.
6.  **Create**.
7.  **QUAN TRỌNG**: Copy đoạn token này ngay lập tức (bạn sẽ không xem lại được).

## 3. Cấu hình Jenkins
### Bước 3.1: Thêm Credentials
1.  Vào Jenkins -> **Manage Jenkins** -> **Manage Credentials**.
2.  Click vào **(global)** -> **Add Credentials**.
3.  **Kind**: Chọn `Username with password`.
4.  **Username**: Tên đăng nhập Azure DevOps của bạn (thường là email).
5.  **Password**: Dán đoạn **PAT** vừa copy ở bước 2.
6.  **ID**: Đặt tên dễ nhớ, ví dụ `azure-git-creds`.
7.  **Create**.

### Bước 3.2: Cấu hình Job
1.  Vào Job `python-cicd` bạn đã tạo -> **Configure**.
2.  Phần **Pipeline** -> **Definition**: `Pipeline script from SCM`.
3.  **SCM**: Chọn `Git`.
4.  **Repository URL**: Dán URL đã copy ở Bước 1.
5.  **Credentials**: Chọn `azure-git-creds` vừa tạo.
    *   *Nếu không báo lỗi đỏ là kết nối thành công.*
6.  **Branch Specifier**: `*/main` (hoặc `*/master` tùy branch chính của bạn).
7.  **Script Path**: `Jenkinsfile`.

## 4. Thiết lập Tự động chạy (Trigger)
Vì Jenkins của bạn có thể đang chạy ở máy cá nhân (Localhost), Azure trên mạng internet không thể gọi về máy bạn được (Webhook không hoạt động trực tiếp). Cách đơn giản nhất là **Polling** (Hỏi định kỳ).

1.  Trong màn hình **Configure** của Job.
2.  Tìm mục **Build Triggers**.
3.  Tích vào **Poll SCM**.
4.  **Schedule**: Nhập `H/2 * * * *`
    *   *Ý nghĩa*: Cứ 2 phút Jenkins sẽ kiểm tra Azure một lần. Nếu có code mới, nó sẽ tự chạy Build.

## 5. Lưu và Chạy thử
1.  Nhấn **Save**.
2.  Thử sửa một chút code trên Azure (hoặc push từ máy lên).
3.  Đợi khoảng 2 phút, bạn sẽ thấy Jenkins tự động chạy Job.

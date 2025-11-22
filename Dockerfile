# 1. Lấy nền Python 3.9 (như cái vỏ thùng)
FROM python:3.9-slim

# 2. Tạo thư mục tên là /app bên trong thùng để làm việc
WORKDIR /app

# 3. Copy file danh sách thư viện vào thùng và cài đặt
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4. Copy toàn bộ code của em vào thùng
COPY . .

# 5. Mở cái lỗ (port) 8000 để người ngoài giao tiếp được
EXPOSE 8000

# 6. Lệnh mặc định: Khi cái thùng được mở (run), chạy ngay lệnh này
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
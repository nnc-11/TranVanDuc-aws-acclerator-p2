# LAB: Detect Sensitive data in Amazon S3 buckets and sent notifications using Amazon Macie

## Đề Bài

![kientruc](/picture/DeBai.jfif)<br>

## Mục Tiêu
- Upload file lên S3
- Amazon Macie quét dữ liệu nhạy cảm
- Macie tạo Findings
- EventBridge bắt sự kiện
- Gửi cảnh báo qua SNS (email)

## Evidence
### 1. S3 bucket + file
- bucket
- file sample.txt trong bucket

![s3 bucket](/picture/E1.png)<br>

### 2. Macie enabled
- Macie overview

![macie](/picture/E2.png)<br>

### 3. Macie job

![macie job ](/picture/E3.png)<br>

![macie](/picture/E6.png)<br>

### 4. SNS Subscription

![macie](/picture/E7.png)<br>

### 5. SNS Email 

![SNS](/picture/E8.png)<br>



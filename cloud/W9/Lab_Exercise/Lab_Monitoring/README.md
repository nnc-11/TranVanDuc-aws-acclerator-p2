# Lab Monitoring: CloudWatch Agent and CPU Alarm via SNS

# Evidence LAB (12/06)

## Lab 1: Installing the CloudWatch Agent on EC2

- File cấu hình CloudWatch Agent đã có trên EC2:

![File agent on EC2](picture/file_agent_on_EC2.png)

- CloudWatch đã nhận metric từ EC2:

![CloudWatch nhận metric từ EC2](picture/cloudwatch%20nh%E1%BA%ADn%20metric%20t%E1%BB%AB%20EC2.png)

## Lab 2: CPU Alarm -> Email Alert via SNS

- Metric CPU tăng cao khi chạy stress test:

![Metric CPU high](picture/metric%20hight.png)

- alarm config:

![alarm config](picture/alarm_config.png)

- SNS config to email.

![SNS](picture/SNS_alert.png)

- CloudWatch Alarm đã chuyển trạng thái và gửi cảnh báo:

![Alarm alert](picture/ALARM_alert.png)

## Comment

Lab đã hoàn thành: CloudWatch Agent chạy trên EC2, CloudWatch nhận được metric, CPU alarm vượt ngưỡng 80% và email alert qua SNS đã được gửi thành công.

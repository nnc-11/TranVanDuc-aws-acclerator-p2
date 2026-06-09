# XB-DN26-119 CDO-02 Trần Văn Đức

## Scenario:

**SCENARIO A — Missed Deadlines**

Sprint 1, Day 4. Task của Dev A đã bị trễ deadline hai lần. Dev A đang bị block vì lỗi version conflict nhưng không chủ động báo với team. Trong khi đó Dev B đang bị idle vì phải chờ phần việc của Dev A.

Kỹ năng cần áp dụng trong tình huống này là feedback theo mô hình SBI: **Situation → Behaviour → Impact**, đồng thời chọn cách trao đổi riêng 1-on-1 thay vì phê bình công khai trước team.

## Role:

Em đặt mình vào vai **Leader** của team.

Vai trò của leader trong tình huống này là hiểu nguyên nhân thật sự, giúp Dev A gỡ blocker, điều phối Dev B để không bị idle, và thiết lập lại cách team báo vấn đề trong sprint.

## Your Solution:

Nếu là leader, em sẽ không nhắc Dev A trước mặt cả team vì cách đó dễ làm bạn ấy xấu hổ hoặc phòng thủ. Em sẽ trao đổi riêng với Dev A trong một buổi 1-on-1 ngắn để hiểu rõ bạn ấy đang vướng ở đâu.

Khi trao đổi, em sẽ dùng SBI feedback:

- **Situation:** Ở Sprint 1, Day 4, task của Dev A đã trễ deadline hai lần.
- **Behaviour:** Dev A gặp version conflict nhưng chưa báo blocker cho team.
- **Impact:** Dev B bị idle, tiến độ sprint bị ảnh hưởng, và team không có đủ thông tin để hỗ trợ kịp thời.

Em có thể nói với Dev A như sau:

> Ở Sprint 1 Day 4, task của bạn đã trễ deadline hai lần. Mình biết bạn đang gặp version conflict, nhưng việc chưa báo blocker làm Dev B phải chờ và ảnh hưởng đến tiến độ sprint. Bạn đang vướng cụ thể ở đâu? Mình sẽ sắp xếp người hỗ trợ để xử lý phần này sớm.

Sau đó, em sẽ cập nhật task của Dev A trên Jira hoặc board thành trạng thái `Blocked`, ghi rõ nguyên nhân là version conflict. Em sẽ phân công Dev B hoặc một bạn có kinh nghiệm hơn pair với Dev A để xử lý blocker ngay, tránh để Dev B tiếp tục ngồi chờ.

Cuối cùng, team cần thống nhất rule rõ ràng: nếu bị block quá 2 giờ thì phải báo ngay trên Slack hoặc cập nhật Jira, không chờ đến daily hôm sau. Việc xin hỗ trợ không phải là yếu kém, mà là cách làm chuyên nghiệp để cả team giữ được tiến độ chung.

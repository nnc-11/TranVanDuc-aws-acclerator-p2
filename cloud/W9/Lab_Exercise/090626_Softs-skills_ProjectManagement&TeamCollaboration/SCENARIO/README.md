# XB-DN26-119 CDO-02 Trần Văn Đức

### SCENARIO A — Missed Deadlines

**Situation:** Sprint 1, Day 4. Dev A's task has missed deadline twice. Dev A is blocked by a version conflict but won't raise it. Dev B is idle and waiting.

**Key skill tested:** SBI feedback (Situation → Behaviour → Impact). 1-on-1 vs public confrontation.

**Rule to learn:** Raise blockers within 2 hours. Asking for help is professional, not weak.

## Bài làm

Trong tình huống này, vấn đề không chỉ nằm ở việc Dev A bị trễ deadline. Điều đáng chú ý hơn là Dev A đang bị kẹt vì xung đột version nhưng lại không nói ra với team. Vì không ai biết Dev A đang bị block, Dev B phải ngồi chờ, còn tiến độ của sprint thì bắt đầu bị ảnh hưởng.

Nếu là leader, em sẽ không gọi Dev A ra để nhắc trước mặt cả team. Cách đó dễ làm Dev A xấu hổ hoặc phòng thủ, sau này có thể còn ngại báo vấn đề hơn. Thay vào đó, em sẽ trao đổi riêng với Dev A trong một buổi 1-on-1 ngắn để hiểu rõ chuyện gì đang xảy ra và giúp bạn ấy tháo gỡ blocker.

Khi nói chuyện với Dev A, em sẽ dùng cách feedback theo SBI:

- **Situation:** Ở Sprint 1, Day 4, task của Dev A đã bị trễ deadline hai lần.
- **Behaviour:** Dev A đang gặp version conflict nhưng chưa báo blocker cho team.
- **Impact:** Dev B bị idle vì phải chờ, sprint có nguy cơ trễ, và team không có đủ thông tin để hỗ trợ kịp thời.

Em có thể nói với Dev A như sau:

> Ở Sprint 1 Day 4, task của bạn đã trễ deadline hai lần. Mình biết bạn đang gặp version conflict, nhưng việc chưa báo blocker làm Dev B phải chờ và ảnh hưởng đến tiến độ sprint. Bạn đang vướng cụ thể ở đâu? Mình sẽ sắp xếp người hỗ trợ để xử lý phần này sớm.

Sau đó, em sẽ nói rõ thêm rằng việc báo blocker không phải là yếu kém. Trong làm việc nhóm, báo vấn đề sớm là cách làm chuyên nghiệp, vì nó giúp cả team cùng kiểm soát rủi ro. Nếu ai đó bị kẹt quá lâu mà không nói, vấn đề nhỏ có thể biến thành chậm tiến độ của cả sprint.

Hướng xử lý tiếp theo là cập nhật task của Dev A trên Jira hoặc board thành trạng thái `Blocked`, ghi rõ nguyên nhân là version conflict. Leader có thể phân công Dev B hoặc một bạn có kinh nghiệm hơn pair với Dev A để xử lý ngay. Việc này vừa giúp Dev A gỡ blocker, vừa giúp Dev B không còn bị idle.

Sau khi xử lý xong, team cần thống nhất lại một rule rõ ràng: nếu bị block quá 2 giờ thì phải báo ngay trên Slack hoặc cập nhật Jira, không chờ đến daily hôm sau. Khi có blocker, người gặp vấn đề cần chủ động nói ra, còn leader cần tạo môi trường để mọi người cảm thấy việc xin hỗ trợ là bình thường.

Kết luận lại, trong kịch bản này nên xử lý bằng trao đổi riêng 1-on-1 và feedback theo SBI, không nên confrontation công khai. Mục tiêu không phải là đổ lỗi cho Dev A, mà là giúp bạn ấy giải quyết vấn đề, tránh Dev B tiếp tục chờ, và bảo vệ tiến độ chung của sprint.

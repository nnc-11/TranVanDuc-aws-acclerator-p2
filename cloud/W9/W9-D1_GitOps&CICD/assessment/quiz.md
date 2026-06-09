# Assessment Answer Key

## Đáp án trắc nghiệm

1. B
2. B
3. A
4. B
5. C
6. C
7. A
8. A
9. B
10. A
11. A
12. B
13. A
14. B
15. A

## Gợi ý trả lời tự luận

1. GitOps lấy Git làm source of truth. Người vận hành thay đổi manifest qua Git/PR, controller như ArgoCD hoặc Flux tự sync cluster. Deploy thủ công bằng `kubectl apply` thay đổi trực tiếp cluster và dễ làm trạng thái thật lệch khỏi Git.

2. Khi mở PR, workflow chạy validate, lint, test, render manifest hoặc `terraform plan`. Khi PR được merge vào `main`, workflow mới chạy apply hoặc cập nhật GitOps repo, sau đó ArgoCD/Flux đồng bộ cluster.

3. Chọn ArgoCD khi cần UI, diff, sync status, health view rõ ràng và onboarding dễ. Chọn Flux khi muốn mô hình Kubernetes-native bằng CRD/controller, nhẹ, modular và mạnh về image automation.

4. App-of-apps dùng một Application cha để quản lý nhiều Application con. Pattern này giúp bootstrap cluster, quản lý nhiều service/addon bằng Git và giảm thao tác tạo app thủ công trong UI.

5. Ưu tiên `git revert` commit lỗi rồi push để GitOps controller sync về trạng thái ổn định. Nếu sự cố khẩn cấp, có thể dùng `kubectl rollout undo` trước để giảm ảnh hưởng, nhưng phải sửa Git ngay sau đó để tránh controller sync lại phiên bản lỗi.

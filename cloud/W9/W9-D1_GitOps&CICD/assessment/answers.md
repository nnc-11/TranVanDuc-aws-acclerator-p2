# Assessment Questions

## Trắc nghiệm

1. GitOps dùng thành phần nào làm source of truth?
   - A. Cluster hiện tại
   - B. Git repository
   - C. Terminal history
   - D. Docker registry

2. Trong GitOps, controller như ArgoCD hoặc Flux thường làm gì?
   - A. Push code lên Git
   - B. Pull desired state từ Git và reconcile cluster
   - C. Tạo pull request
   - D. Thay thế toàn bộ CI

3. CI thường bao gồm hoạt động nào?
   - A. Lint, test, build, scan
   - B. Xóa namespace production
   - C. Rollback thủ công
   - D. Tạo user IAM bằng tay

4. `plan-on-PR` có mục tiêu chính là gì?
   - A. Apply trực tiếp production
   - B. Cho reviewer thấy tác động trước khi merge
   - C. Tắt workflow
   - D. Bỏ qua test

5. `apply-on-merge` thường chạy khi nào?
   - A. Khi mở PR
   - B. Khi comment vào issue
   - C. Khi push/merge vào nhánh tin cậy như `main`
   - D. Khi clone repo

6. Với PR từ fork, điều gì cần tránh?
   - A. Chạy lint
   - B. Chạy test
   - C. Expose secret hoặc quyền apply production
   - D. Checkout code

7. Điểm mạnh nổi bật của ArgoCD là gì?
   - A. UI quan sát diff, sync và health
   - B. Không cần Kubernetes
   - C. Chỉ chạy được Terraform
   - D. Không cần Git

8. Flux phù hợp với phong cách vận hành nào?
   - A. Kubernetes-native bằng CRD/controller
   - B. Chỉ thao tác bằng UI
   - C. Không dùng Git
   - D. Chỉ dùng cho VM truyền thống

9. App-of-apps trong ArgoCD là gì?
   - A. Một Deployment có nhiều container
   - B. Một Application cha quản lý nhiều Application con
   - C. Một Helm chart không có values
   - D. Một GitHub Action

10. Mục đích của app-of-apps là gì?
    - A. Bootstrap và quản lý nhiều app bằng Git
    - B. Tắt auto sync
    - C. Xóa toàn bộ cluster
    - D. Thay thế Dockerfile

11. Sync waves dùng để làm gì?
    - A. Sắp xếp thứ tự apply resource khi ArgoCD sync
    - B. Build container image
    - C. Tạo Git tag
    - D. Chạy unit test

12. Resource không có annotation sync wave mặc định thuộc wave nào?
    - A. `-1`
    - B. `0`
    - C. `1`
    - D. `999`

13. Trường hợp nào nên dùng sync wave?
    - A. CRD cần có trước custom resource
    - B. Muốn đổi màu UI
    - C. Muốn clone repo nhanh hơn
    - D. Muốn tắt readiness probe

14. Rollback chuẩn trong GitOps nên dùng cách nào?
    - A. Sửa trực tiếp cluster rồi bỏ qua Git
    - B. `git revert` và để controller sync lại
    - C. Xóa Git repository
    - D. Tắt ArgoCD vĩnh viễn

15. Rủi ro chính của `kubectl rollout undo` trong GitOps là gì?
    - A. Không cập nhật Git, có thể bị controller sync lại phiên bản lỗi
    - B. Tự động tạo PR
    - C. Không thể dùng với Deployment
    - D. Luôn xóa namespace

## Tự luận

1. Giải thích ngắn gọn GitOps khác deploy thủ công bằng `kubectl apply` như thế nào.
2. Mô tả luồng `plan-on-PR` và `apply-on-merge` trong GitHub Actions.
3. Khi nào bạn chọn ArgoCD, khi nào bạn chọn Flux?
4. App-of-apps giúp ích gì khi quản lý nhiều service trong một cluster?
5. Nếu production lỗi sau deploy, bạn sẽ rollback thế nào để vẫn đúng tinh thần GitOps?

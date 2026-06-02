# Troubleshooting

## Loi moi truong chay khi apply/destroy

Tai lieu nay thong ke cac loi da gap trong qua trinh chay Terraform lab EC2 va cach fix tuong ung.

## 2. Nhap `yes` nhung bi `Apply cancelled` hoac `Destroy cancelled`

Loi:

```text
Apply cancelled.
Destroy cancelled.
```

Nguyen nhan:

Terraform chỉ chấp nhận chuỗi `yes` ở prompt xac nhan. Trong moi truong terminal/session hien tai, input từ prompt không ổn định Terraform không nhận đúng.

Cach fix:

Dung che do non-interactive khi chay lab:

```bash
terraform apply -auto-approve
terraform destroy -auto-approve
```

Neu gap loi provider plugin khi chay tren duong dan /mnt/g, co the dung them plugin cache:
lí do: Do workspace nằm trên ổ Windows mount qua WSL (/mnt/...), aws provider plugin trong .terraform có thể lỗi khi terraform load plugin. Fix: đặt lplugin cache sang /tmp/.. trên filesystem linux rồi chạy lại terraform init. (trường hợp chậy không lỗi k cần dùng /tmp)

```bash
TF_PLUGIN_CACHE_DIR=/tmp/tf-plugin-cache terraform apply -auto-approve
TF_PLUGIN_CACHE_DIR=/tmp/tf-plugin-cache terraform destroy -auto-approve
```

## 3. AWS provider plugin bi loi schema

Loi:

```text
Failed to load plugin schemas
Failed to read any lines from plugin's stdout
```

Nguyen nhan:

AWS provider plugin trong thu muc `.terraform` khong khoi dong dung. Lab dang chay tren duong dan Windows mount `/mnt/g`, nen provider cache trong workspace co the bi loi khi Terraform load plugin.

Cach fix:

Xoa cache `.terraform` loi va init lai bang plugin cache tren Linux filesystem:

```bash
rm -rf .terraform
mkdir -p /tmp/tf-plugin-cache
TF_PLUGIN_CACHE_DIR=/tmp/tf-plugin-cache terraform init
```

Sau do tiep tuc chay Terraform voi cung bien moi truong:

```bash
TF_PLUGIN_CACHE_DIR=/tmp/tf-plugin-cache terraform plan
TF_PLUGIN_CACHE_DIR=/tmp/tf-plugin-cache terraform apply -auto-approve
```

## 4. Default VPC khong co subnet

Loi:

```text
No subnets found for the default VPC
```

Nguyen nhan:

Default VPC van ton tai, nhung khong co default subnet. EC2 can subnet de launch instance, nen neu khong chi dinh `subnet_id` thi apply se fail.

Cach fix:

Them data source lay availability zone:

```hcl
data "aws_availability_zones" "available" {
  state = "available"
}
```

Them subnet do Terraform quan ly:

```hcl
resource "aws_subnet" "web" {
  vpc_id                  = data.aws_vpc.default.id
  cidr_block              = cidrsubnet(data.aws_vpc.default.cidr_block, 8, 10)
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-subnet"
    Project     = var.project_name
    Environment = "training"
    ManagedBy   = "terraform"
  }
}
```

Gan EC2 vao subnet:

```hcl
subnet_id = aws_subnet.web.id
```

## 5. Instance type khong hop le voi Free Tier

Loi:

```text
InvalidParameterCombination: The specified instance type is not eligible for Free Tier
```

Nguyen nhan:

`t2.micro` khong duoc AWS account/region hien tai chap nhan la Free Tier eligible.

Cach fix:

Kiem tra instance type Free Tier hop le:

```bash
aws ec2 describe-instance-types \
  --region ap-southeast-1 \
  --filters Name=free-tier-eligible,Values=true \
  --query 'InstanceTypes[].InstanceType' \
  --output text
```

Doi instance type sang `t3.micro`:

```hcl
variable "instance_type" {
  description = "EC2 instance type for the lab."
  type        = string
  default     = "t3.micro"
}
```

## Kiem tra sau khi fix

Kiem tra resource dang duoc Terraform state quan ly:

```bash
TF_PLUGIN_CACHE_DIR=/tmp/tf-plugin-cache terraform state list
```

Ket qua mong doi co cac address:

```text
data.aws_ami.amazon_linux
data.aws_availability_zones.available
data.aws_vpc.default
aws_instance.web
aws_security_group.web
aws_subnet.web
```

Kiem tra output:

```bash
TF_PLUGIN_CACHE_DIR=/tmp/tf-plugin-cache terraform output
```

Ten output mong doi:

```text
instance_id
public_ip
security_group_id
```

## Don dep thu muc Terraform

File/thu muc can giu:

```text
.terraform/
.terraform.lock.hcl
terraform.tfstate
```

File backup state co the ton tai sau apply:

```text
terraform.tfstate.backup
```

Xoa cache cu neu con:

```bash
rm -rf .terraform.reinit-backup
```

# Quiz

## Multiple-Choice Questions

1. What is Infrastructure as Code?
   - A. Manually creating infrastructure in the AWS Console
   - B. Defining infrastructure using code files
   - C. Writing application code only
   - D. Taking screenshots of cloud resources

2. Which Terraform command downloads required providers?
   - A. `terraform plan`
   - B. `terraform init`
   - C. `terraform destroy`
   - D. `terraform output`

3. What does the AWS provider do?
   - A. Stores application logs
   - B. Translates Terraform resource actions into AWS API calls
   - C. Replaces IAM permissions
   - D. Creates Git commits

4. What is Terraform state used for?
   - A. Mapping Terraform configuration to real infrastructure
   - B. Formatting HCL files
   - C. Installing the AWS CLI
   - D. Creating SSH keys

5. Which command previews infrastructure changes?
   - A. `terraform fmt`
   - B. `terraform plan`
   - C. `terraform output`
   - D. `terraform version`

6. Which command applies planned infrastructure changes?
   - A. `terraform apply`
   - B. `terraform init`
   - C. `terraform validate`
   - D. `terraform state list`

7. Which file extension is commonly used for Terraform configuration?
   - A. `.yaml`
   - B. `.tf`
   - C. `.jsonnet`
   - D. `.ini`

8. In `resource "aws_instance" "web"`, what is `web`?
   - A. The Terraform local resource name
   - B. The AWS region
   - C. The AMI owner
   - D. The provider version

9. What should you usually avoid committing to Git?
   - A. `README.md`
   - B. `main.tf`
   - C. `terraform.tfstate`
   - D. `quiz.md`

10. What does `terraform fmt` do?
    - A. Formats Terraform configuration
    - B. Deletes AWS resources
    - C. Creates a VPC
    - D. Configures AWS credentials

11. What does `terraform validate` check?
    - A. Whether the configuration is syntactically valid
    - B. Whether your EC2 instance is reachable by SSH
    - C. Whether your bill is zero
    - D. Whether GitHub is connected

12. Which Terraform block configures the AWS region?
    - A. `output`
    - B. `provider "aws"`
    - C. `resource "local_file"`
    - D. `data "template_file"`

13. What is a data source in Terraform?
    - A. A way to query existing information
    - B. A database backup file
    - C. A Git branch
    - D. A shell script

14. Why should SSH ingress not be open to `0.0.0.0/0` in production?
    - A. It blocks Terraform state
    - B. It allows SSH attempts from anywhere
    - C. It disables EC2 tags
    - D. It prevents `terraform init`

15. What is the purpose of outputs?
    - A. To display useful values after apply
    - B. To store AWS secret keys
    - C. To skip provider installation
    - D. To format Markdown

16. Which command removes resources managed by the current state and configuration?
    - A. `terraform destroy`
    - B. `terraform fmt`
    - C. `terraform providers`
    - D. `terraform login`

17. What is one reason to use remote state in a team?
    - A. To make EC2 larger
    - B. To coordinate shared infrastructure changes
    - C. To avoid writing HCL
    - D. To remove IAM requirements

18. What is HCL?
    - A. HashiCorp Configuration Language
    - B. Hosted Cloud Loader
    - C. Hardware Control Layer
    - D. Hyperlink Command Language

19. What does Terraform use to understand dependencies between resources?
    - A. Dependency graph
    - B. Browser cookies
    - C. EC2 user data only
    - D. Git commit messages

20. What should you do after finishing a paid AWS lab?
    - A. Leave resources running
    - B. Run `terraform destroy` and verify cleanup
    - C. Delete only local files
    - D. Ignore the AWS Console

## Short-Answer Questions

1. Explain IaC in your own words.
2. What is the difference between `terraform plan` and `terraform apply`?
3. Why is Terraform state important?
4. Name two risks of managing infrastructure manually through the AWS Console.
5. Why should secrets and state files not be committed to Git?

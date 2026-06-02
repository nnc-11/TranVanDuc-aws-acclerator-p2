# Terraform Part 1 — IaC & HCL Fundamentals (AWS)

> Self-study Terraform - Day 01
> Learn Terraform basics by building and managing an AWS EC2 instance.

## Learning objectives.

* Infrastructure as Code (IaC) overview
* Terraform architecture and AWS Provider
* Terraform workflow basics (`init` → `plan` → `apply` → `destroy`)
* HCL syntax 
* Terraform state fundamentals
* Deploying an EC2 instance on AWS

## Prerequisites

* AWS Account
* AWS CLI configured
* Terraform installed
* Basic Linux and AWS knowledge

## Study Plan

| Step | Activity                                            |
| ---- | --------------------------------------------------- |
| 1    | Read `knowledge/01-iac-overview.md`                 |
| 2    | Read `knowledge/02-terraform-architecture.md`       |
| 3    | Read `knowledge/03-terraform-workflow.md`           |
| 4    | Read `knowledge/04-hcl-syntax.md`                   |
| 5    | Complete `lab/requirements.md`                      |
| 6    | Follow `lab/implementation-guide.md`                |
| 7    | Verify with `lab/validation-checklist.md`           |
| 8    | Troubleshoot using `lab/troubleshooting.md`         |
| 9    | Complete `assessment/quiz.md`                       |
| 10   | Review `assessment/answers.md`                      |
| 11   | Record notes in `notes/lessons-learned-template.md` |

## Expected Outcome

After completing this module, you will be able to:

* Create and manage AWS resources with Terraform
* Read and write basic HCL
* Understand Terraform state and lifecycle
* Deploy and remove an EC2 instance safely

## Estimated Time

**4–6 hours**

* Theory: 2–3h
* Lab: 1.5–2h
* Assessment: ~1h

## Security Notes

Never commit:

* `.terraform/`
* `terraform.tfstate*`
* AWS credentials
* Private keys (`*.pem`)
* Sensitive screenshots

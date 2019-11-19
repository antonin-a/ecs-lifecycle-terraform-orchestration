# ECS Lifecycle orchestration using Terraform
--------------------

The goal of this project is to allow users to orchestrate their Flexible Engine Cloud ECS lifecycle using Terraform. This plan can be executed as a cron job in order to create/delete ECS automatically with persistent data/volumes.

## Requirements
-	[Terraform](https://www.terraform.io/downloads.html) 0.12+

## Prerequisites
In order to create the instances, this plan require the following FE ressources:
- A comlete VPC with a subnet
- An existing keypair
- At least one security security group
- An existing bootable system disk
- An existing data disk (can be removed)

## Quick Start
### Initialisation
- Clone this repository
- Edit the FE.rc file with your own credentials/parameters
- Source the FE.rc file
  `  source FE.rc`
- Copy the parameters.tfvars to a .auto.tfvars file (this file will be automatically used when performing terraform plan/apply)
  `cp parameters.tfvars my-parameters.auto.tfvars`
- Edit your .auto.tfvars file with your own parameters values
- Terraform Initialisation
  `terraform init`

### Lifecycle
1. Creation:
  ```
  terraform plan  
  terraform apply
  ```
2. Suppression
  ```
  terraform destroy
  ```
## How to orchestrate existing ECS(s)
  1. Stop the existing ECS(s)
  2. Detach system and data disk(s)
  3. Delete ECS(s)
  4. Add your system and data disks uuid to your .tfvars file
  ```
  system_disks = ["first-system-disk-id","second-system-disk-id","..."]
  data_disks = ["irst-data-disk-id","second-data-disk-id","..."]
  ```
### (Optional) Use Flexible Engine Object Storage (OBS) to store your .tfstafe files
  ```
  terraform {

    backend "s3" {
      bucket = "your-bucket-name"
      key    = "your-terraform-plan-name"
      region = "eu-west-0"
      endpoint = "https://oss.eu-west-0.prod-cloud-ocb.orange-business.com"
      skip_region_validation      = true
      skip_credentials_validation = true
    }
  }
  ```

## Limitations
- ECS creation should be perform on the same AZ as existing EVS (you can't create an ECS on AZa with EVS on AZb)
- Data disk are not automatically mounted at OS level (WIP)

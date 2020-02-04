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
### Terraform workspaces
This project is using Terraform Workspace features, before editing .tfvars file you should create multiple workspaces
```
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod
```
- Edit your .auto.tfvars file with your own parameters values for each terraform workspace. Ex:
```
instance_name     = ({
                    dev         = "ecs-dev"
                    staging     = "staging-dev"
                    prod        = "prod-dev"
                  })
system_disk       =  ({
                    dev         = "system_disk-id-dev"
                    staging     = "system_disk-id-staging"
                    prod        = "system_disk-id-prod"
                  })
data_disk         =  ({
                    dev         = "data_disk-id-dev"
                    staging     = "data_disk-id-staging"
                    prod        = "data_disk-id-prod"
                  })
fixed_ip          =  ({
                   dev          = "private-fixed_ip-dev"
                   staging      = "private-fixed_ip-staging"
                   prod         = "private-fixed_ip-prod"
                  })
```
### Lifecycle

1. Terraform Initialisation
  `terraform init`

2. Creation:
- Select the required workspace:
` terraform workspace select dev`
- Deploy the ressources:
  ```
  terraform plan  
  terraform apply
  ```
3. Suppression
- Select the required workspace:
` terraform workspace select dev`
- Delete the ressources:
  ```
  terraform destroy
  ```
## How to orchestrate existing ECS(s)
  1. Stop the existing ECS(s)
  2. Detach system and data disk(s)
  3. Delete ECS(s)
  4. Add your system and data disks uuid to your .tfvars file
  ```
  system_disk = "system-disk-id"
  data_disk = "data-disk-id"
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
- ECS creation should be performed on the same AZ as existing EVS (you can't create an ECS on AZa with EVS on AZb)


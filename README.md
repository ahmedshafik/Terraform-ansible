# Terraform-Ansible

A simple terraform script to provision an instance on AWS and then run a simple ansible runbook installing ngnix


# Pre-installed package: 

 - AWS CLI
 - Python
 - Terraform
 - Ansible


## passing the keys to terraform:

The access and private keys can be passed to terrafrom in two ways

 - use aws cli profile "already configured with keys" and pass the profile name to terraform, so terraform will access the aws as with the profile
 - pass the keys directly to terraform, this can be edited under (terraform.tfvars)

## To run the script

- clone the project to your server
- move the "Nginx-AnsibleRole" directory to "/etc/ansible/roles"
- download the aws instance key pairs and 
- update terraform.tfvars with the appropriate values
* commands to run the project
    * terraform init
    * terraform plan
    * terraform apply


## screenshots while terraform and ansible are running


![running terraform apply 1](https://user-images.githubusercontent.com/7353494/42449092-a44bf442-837f-11e8-8ad6-f1c419fa05a8.png)

by this momen you can find a newly created instance on aws

#Terraform is running ansible runbook
![terraform running ansible](https://user-images.githubusercontent.com/7353494/42449094-a4acb336-837f-11e8-939f-fb43c1c73495.png)



# Terraform-ansible
A simple terraform script to provision an instance on AWS and then run a simple  ansible runbook   installing ngnix 


First of all please make sure that your server has the below packages installed:
1- AWS CLI
2- Python
3- Terraform
4- Ansible

Afterwards you will have to options:
1-	use your AWS account Access and Private keys directly, or create an AWS CLI profile and pass the profile name to Terraform "This can be edited in (terraform.tfvars)


#AWS PROFILE IMG HERE


To create an AWS CLI profile: 
- aws configure --profile PROFILENAME

You should fill the entries with your AWS configurations.

Under terraform.tfvars :
Please fill the below Variables. 
aws_profile = “PROFILENAME”
aws_region = “REGIONHERE” 
Private_Key_Path = "PrivateKey here.pem"         
Ansible_RunBook = "ansiblestart.yml
The ansible role will make sure that python is installed, install nginx and start the service 

To run they project:
1-	Copy the Nginx-AnsibleRole directory to /etc/ansible/roles
2-	Update terraform.tfvars  AWS_instance_KEY = "Your AWS Instance key" with the name of they key that the instance will use
3-	Copy AWS instance private key to the terraform path and update the terraform.tfvars  Private_Key_Path = "PrivateKey"    
4-	Run the below commands:
1-	Terraform init
2-	Terraform plan
3-	Terraform apply

# Project Image here

You should see find the aws instance in being creating on your cloud.




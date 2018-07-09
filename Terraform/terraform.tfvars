#passing variables to variables.tf


aws_profile = "PROFILENAME"                  //AWS CLI Profile   
aws_region  = "eu-central-1"                    //AWS Region
AWS_instance_KEY = "Your AWS Instance key"      //Instance Key
Private_Key_Path = "PrivateKey"          //Private Key location
Ansible_RunBook = "ansiblestart.yml"            // Ansible runbook


#You can use Secret and access key rather than AWS CLI Profile
//secret_key  = "xxxxx"                    
//access_key  = "xxxxx"
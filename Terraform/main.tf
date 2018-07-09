provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"

  # access_key = "${var.aws_access_key}"
  # secret_key = "${var.aws_secret_key}"  
}

#----------AMI----------- //image to choose from

data "aws_ami" "ubuntuimg" {
  most_recent = true // will choose the most recent ubuntu image from the returned list

#filtering the AMI to get ubuntu Images
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

#Filtering the v.type to be HVM
  filter {
    name = "virtualization-type"
    values= ["hvm"]
  }
}

#----------Instance----------- Creating the AWS instance 
resource "aws_instance" "terra-ansible" {
  ami = "${data.aws_ami.ubuntuimg.id}"
  instance_type = "t2.micro"                            //Instance AWS type
  key_name = "${var.AWS_instance_KEY}"                              //Private Key to be assigned to machine
  
  tags {
    Name = "Terraform-Ansible"                         //Instance Name
  }

  provisioner "local-exec" {
    # running the ansible-playbook
    command    = " sleep 60 ; ansible-playbook -u ubuntu -i '${self.public_ip},' --private-key ${var.Private_Key_Path} ${var.Ansible_RunBook}"
    on_failure = "continue"

}
}


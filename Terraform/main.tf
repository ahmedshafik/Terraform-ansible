provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"

  # access_key = "${var.aws_access_key}"
  # secret_key = "${var.aws_secret_key}"  
}

#Creating VPC
resource "aws_vpc" "ROR-VPC" {

    cidr_block = "${var.vpc_cidr_block}"
    enable_dns_hostnames = true
    tags {
        Name = "ROR-VPC"
    }
}

# Creating subnets

#Public subnet

resource "aws_subnet" "Public-Subnet" {
  vpc_id = "${aws_vpc.ROR-VPC.id}"
  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "${var.aws_zone_a}"
  map_public_ip_on_launch = true

  tags{
      Name = "Public Subnet"
  }

}

#Priavte subnet

#Zone A
resource "aws_subnet" "Private_Subnet" {
  vpc_id = "${aws_vpc.ROR-VPC.id}"
  cidr_block = "${var.private_subnet_cidr}"
  availability_zone = "${var.aws_zone_a}"

  tags{
      Name = "Private Subnet"
  }

}

#Zone B
resource "aws_subnet" "Private_Subnet_z2" {
  vpc_id = "${aws_vpc.ROR-VPC.id}"
  cidr_block = "${var.private_subnet_cidr_z2}"
  availability_zone = "${var.aws_zone_b}"

  tags{
      Name = "Private Subnet ZoneB"
  }

}

#Internet Gatway
resource "aws_internet_gateway" "Internet_GW" {
    vpc_id = "${aws_vpc.ROR-VPC.id}"

   tags {
    Name = "ROR-GW"
}
}

#Public Subnet RouteTable

resource "aws_route_table" "Public_RT" {
    vpc_id = "${aws_vpc.ROR-VPC.id}"

    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.Internet_GW.id}"
    }

    tags {
    Name = "Public Subnet RT"
}  
}

# Create Nat GW
resource "aws_nat_gateway" "Nat-GW" {
  subnet_id = "${aws_subnet.Public-Subnet.id}"
  allocation_id = "${var.ElasticGW_ID}"
  depends_on = ["aws_internet_gateway.Internet_GW"]
  
  tags {
      Name = "Nat GW"
  }
}
# Assign RT to Public subnet

resource "aws_route_table_association" "PubRT-PubSN" {
  subnet_id = "${aws_subnet.Public-Subnet.id}"
  depends_on = ["aws_route_table.Public_RT"]
  route_table_id = "${aws_route_table.Public_RT.id}"
}

#Private Subnet RouteTable
resource "aws_route_table" "Private_RT" {
    vpc_id = "${aws_vpc.ROR-VPC.id}"

    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_nat_gateway.Nat-GW.id}"
    }

    tags {
    Name = "Private Subnet RT"
}  
}

# Assign RT to Private subnet

resource "aws_route_table_association" "PriRT-PriSN" {
  subnet_id = "${aws_subnet.Private_Subnet.id}"
  depends_on = ["aws_route_table.Private_RT"]
  route_table_id = "${aws_route_table.Private_RT.id}"
}

resource "aws_route_table_association" "PriRT-PriSNB" {
  subnet_id = "${aws_subnet.Private_Subnet_z2.id}"
  depends_on = ["aws_route_table.Private_RT"]
  route_table_id = "${aws_route_table.Private_RT.id}"
}


#Security Groups to Allow SSH, PostGresql and HTTP/s

resource "aws_security_group" "SGSSH" {
  vpc_id = "${aws_vpc.ROR-VPC.id}"
  name = "Allow-SSH"
  description = "Security Group to allow SSH"

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      self = true
  }
  tags{
      Name = "cg-ssh"
  }
}

resource "aws_security_group" "SGICMP" {
  vpc_id = "${aws_vpc.ROR-VPC.id}"
  name = "Allow-ICMP"
  description = "Security Group to allow ICMP"

  ingress {
      from_port = -1
      to_port = -1
      protocol = "icmp"
      cidr_blocks = ["0.0.0.0/0"]
      self = true
  }
  egress
  {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  tags{
      Name = "cg-icmp"
  }
}

resource "aws_security_group" "SGHTTPS" {
  vpc_id = "${aws_vpc.ROR-VPC.id}"
  name = "Allow-HTTPs"
  description = "Security Group to allow HTTP/s"

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      self = true
  } 
   egress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      self = true
  }
   tags{
      Name = "cg-https"
  }
}

resource "aws_security_group" "SGPSQL" {
  vpc_id = "${aws_vpc.ROR-VPC.id}"
  name = "Allow-Postgresql"
  description = "Security Group to allow PostgreSQL"

  ingress {
      from_port = 5432
      to_port = 5432
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
      from_port = 5432
      to_port = 5432
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      self = true
  }
   tags{
      Name = "cg-pssql"
  }
}

#Creating ECR, Pushing image to it
resource "aws_ecr_repository" "ror_repo" {
  name = "ror-repo"
  //provisioner "local-exec" {
  //  command = "Curl Jenkins API to push Image"

}

#Creating RDS PostGreSQL

#Create RDS subnet group
resource "aws_db_subnet_group" "pgsql-sg" {
  name = "pgsql-sg"
  subnet_ids = ["${aws_subnet.Private_Subnet.id}","${aws_subnet.Private_Subnet_z2.id}"]
}


resource "aws_db_instance" "pgsql" {
  allocated_storage = 5
  engine = "postgres"
  instance_class = "db.t2.micro"
  name = "pgsqldb"
  username = "${var.DB_uname}"
  password = "${var.DB_password}"
  port = 5432
  db_subnet_group_name = "${aws_db_subnet_group.pgsql-sg.name}"
  skip_final_snapshot = true
}





# #----------AMI----------- //image to choose from

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
resource "aws_instance" "AppServer" {
  ami      = "${data.aws_ami.ubuntuimg.id}"
  key_name = "${var.AWS_instance_KEY}"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.Private_Subnet.id}"
  depends_on = ["aws_nat_gateway.Nat-GW"]
  vpc_security_group_ids = ["${aws_security_group.SGPSQL.id}","${aws_security_group.SGSSH.id}","${aws_security_group.SGHTTPS.id}","${aws_security_group.SGICMP.id}"]
  tags {
      Name = "App Server"
  }
}

resource "aws_instance" "bastion" {
  ami      = "${data.aws_ami.ubuntuimg.id}"
  key_name = "${var.AWS_instance_KEY}"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.Public-Subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.SGPSQL.id}","${aws_security_group.SGSSH.id}","${aws_security_group.SGHTTPS.id}","${aws_security_group.SGICMP.id}"]
  depends_on = ["aws_ecr_repository.ror_repo","aws_instance.AppServer"]
   tags {
      Name = "Jump Server"
  }


  
    connection{
        user = "ubuntu"
        private_key = "${file("${var.Private_Key_Path}")}"
    }

    provisioner "local-exec" {
    # running the ansible-playbook
    command    = " sleep 90 ; export ANSIBLE_HOST_KEY_CHECKING=False;ansible-playbook -u ubuntu -i '${self.public_ip},' --private-key ${var.Private_Key_Path} ${var.Ansible_RunBook}"
    on_failure = "continue"
    }

  provisioner "file" {
    source      = "${var.Private_Key_Path}"
    destination = "/home/ubuntu/key.pem"
  }
    provisioner "file" {
    source      = "${var.Ansible_RunBook}"
    destination = "/home/ubuntu/rolestart.yml"
  }
    provisioner "remote-exec" {
        inline = ["sleep 90",
          "chmod 700 /home/ubuntu/key.pem" ,
        "export ANSIBLE_HOST_KEY_CHECKING=False",
        "ansible-playbook -u ubuntu -i '${aws_instance.AppServer.private_ip},' --private-key key.pem rolestart.yml",
        "rm -rf /key.pem"
        ]
    
    }
}


output "ror-repo-URL" {
  value = "${aws_ecr_repository.ror_repo.repository_url}"
}
output "Jump-Server-IP" {
  value = "${aws_instance.bastion.public_ip}"
}

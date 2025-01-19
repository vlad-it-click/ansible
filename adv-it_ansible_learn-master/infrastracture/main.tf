# ---------------------------------------------------------
# Infrastracturi in aws for learning Ansible
#
# Infrastracture is are representing from 3 vm EC2 instances
#
# Owner Iurie Topor
# ---------------------------------------------------------


provider "aws" {
  region = "eu-central-1"
}

data "aws_vpc" "default" {
  default = true
}


# VAR ---------------------------------------------------------------
#
variable "image_id" {
  type        = string
  description = "The id of the machine image (AMI) to use for the server."

  validation {
    condition     = length(var.image_id) > 4 && substr(var.image_id, 0, 4) == "ami-"
    error_message = "The image_id value must be a valid AMI id, starting with \"ami-\"."
  }
}

variable "key_path" {
  type = string
}

variable "env_path" {
  type = string
}

variable "key_list" {
  type = list(string)
}


# KEYS --------------------------------------------------------------
#
resource "aws_key_pair" "key_1" {
  key_name   = "AC-Ubuntu-1"
  public_key = file("${var.key_path}/${var.key_list[0]}.pub")
}

resource "aws_key_pair" "key_X" {
  key_name   = "AC-Ubuntu-X"
  public_key = file("${var.key_path}/${var.key_list[1]}.pub")
}


# INSTANCES ---------------------------------------------------------
#
// Ansible Client 1 Ubuntu
resource "aws_instance" "ansible_client_1" {
  key_name = aws_key_pair.key_1.key_name

  ami                    = "ami-05ff5eaef6149df49"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.main_security_group.id]

  tags = {
    Name  = "Ansible-Client-1-Ubuntu"
    Owner = "Iurie Topor"
  }
}

// Ansible Client 2 Ubuntu
resource "aws_instance" "ansible_client_2" {
  key_name = aws_key_pair.key_1.key_name

  ami                    = var.image_id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.main_security_group.id]

  tags = {
    Name  = "Ansible-Client-2-Ubuntu"
    Owner = "Iurie Topor"
  }
}

// Ansible Client X Ubuntu
resource "aws_instance" "ansible_client_X" {
  key_name = aws_key_pair.key_X.key_name

  ami                    = var.image_id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.main_security_group.id, aws_security_group.jenkins_security_group.id]

  tags = {
    Name  = "Ansible-Client-X-Ubuntu"
    Owner = "Iurie Topor"
  }
}

# NETWORK -----------------------------------------------------------
#
// Security Group
resource "aws_security_group" "main_security_group" {
  vpc_id = data.aws_vpc.default.id

  name        = "Ansible Security Group"
  description = "Test SG for learning Ansible"

  dynamic "ingress" {
    for_each = ["22", "80", "443"]
    content {
      // description = "SSH"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "Ansible Security Group"
    Owner = "Iurie Topor"
  }
}

resource "aws_security_group" "jenkins_security_group" {
  vpc_id = data.aws_vpc.default.id

  name        = "Jenkins Security Group"
  description = "Test SG for learning Ansible"

  dynamic "ingress" {
    for_each = ["8080"]
    content {
      // description = "SSH"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "Ansible Security Group For Jenkins_Server"
    Owner = "Iurie Topor"
  }
}


# OUTPUT ------------------------------------------------------------
#
output "public_ip_AC-ubuntu-1" {
  value = aws_instance.ansible_client_1.public_ip
}

output "public_ip_AC-ubuntu-2" {
  value = aws_instance.ansible_client_2.public_ip
}

output "public_ip_AC-ubuntu-X" {
  value = aws_instance.ansible_client_X.public_ip
}


# OUTPUT_FILE -------------------------------------------------------
#
data "template_file" "hosts_txt" {
  template = file("${var.env_path}/hosts.tpl")

  vars = {
    user_1 = "ec2-user"
    host_x = join("", ["linux ansible_host=", aws_instance.ansible_client_X.public_ip])
    host_1 = join("", ["linu1 ansible_host=", aws_instance.ansible_client_1.public_ip])
    host_2 = join("", ["linu2 ansible_host=", aws_instance.ansible_client_2.public_ip])
  }
}

data "template_file" "all_servers" {
  template = file("${var.env_path}/all_servers.tpl")

  vars = {
    user = "ubuntu"
  }
}

data "template_file" "prod_servers" {
  template = file("${var.env_path}/prod_servers.tpl")

  vars = {
    key_1 = "${var.key_path}/${var.key_list[0]}"
  }
}

data "template_file" "staging_servers" {
  template = file("${var.env_path}/staging_servers.tpl")

  vars = {
    key_x = "${var.key_path}/${var.key_list[1]}"
  }
}


resource "local_file" "save_inventory" {
  content = data.template_file.hosts_txt.rendered
  #filename = "home/sweetuser/adv-it/ansible_learn/hosts.txt"
  filename = "../hosts.txt"
}

resource "local_file" "save_all_serv" {
  content  = data.template_file.all_servers.rendered
  filename = "../group_vars/all_servers"
}

resource "local_file" "save_prod_serv" {
  content  = data.template_file.prod_servers.rendered
  filename = "../group_vars/prod_servers"
}

resource "local_file" "save_staging_serv" {
  content  = data.template_file.staging_servers.rendered
  filename = "../group_vars/staging_servers"
}


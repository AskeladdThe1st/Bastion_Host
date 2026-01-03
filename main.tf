provider "aws" {
  region = "us-west-2"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = var.enable_nat_gateway
  create_elasticache_subnet_group = false
  single_nat_gateway = true
  create_redshift_subnet_group = false

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
// Bastion Host  -- Bouncer
resource "aws_instance" "bastion_host" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.bastion_instance_type
  security_groups = [aws_security_group.bastion_sg.id]
  subnet_id     = module.vpc.public_subnets[0]
  key_name = aws_key_pair.deployer.key_name
  associate_public_ip_address = true

  tags = {
    Name = "Bastion Host"
  }
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Security group for Bastion Host"
  vpc_id      = module.vpc.vpc_id
  

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_key_pair" "deployer" {
  key_name   = "my-bastion-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC3u4HQed7B867RJj/2P9/fNe2knnCy2PYpE3wJ2J6h/vZqoH22tcP7hopjY1b4Cz7+VBdKRY6lojvR8zxWb9njn9JZtT8kNS+CmoMekJz1m4Qdg11Vdl0HgtyZ241HdggNHge8NIVnTaTe3mrKjsKay6nHHhocGG2Wlb3USsIHfP6SKT01OBfvR5e6UfBVi8Yw72KL8sqW94+BnN5RSA+lojKZBAXne3kk4eX0bdqviI/PopOWHeqn1CZXq3bUBeiMy2pmLwc+JLh4NUVAOD920kQSuJ81Sm22L0q0QUF21tq+tWZ4RwNgzX3wit4VOTK3bvFtkOwaaoycY7lCg+/esaCxm6vY/pLZ5RTfbGOS60j+RenHJklJf/oZxk4upUJC/oZfQQqsXlDUDGlyoH0z95aZ2fcSHbV2GSg23q2TmLAO2o0ywHk4tx2LlUMGvLeeYxFev2ASIQGPuQIureRrm+/o3ahnihB/gR6KsIdWGEm94oWKEWNISRdMflmt9R8= yusuf@Rehman"
}

// ----------------- App Server -----------------


resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.app_instance_type
  subnet_id     = module.vpc.private_subnets[0]
  security_groups = [aws_security_group.app_sg.id]
  key_name = aws_key_pair.deployer.key_name

  tags = {
    Name = "App Server"
  }
}
resource "aws_security_group" "app_sg" {
  name        = "app_sg"
  description = "Security group for App Server"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [aws_security_group.bastion_sg.id]
  }
}


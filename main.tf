module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.vpc_cidr

  azs = data.aws_availability_zones.azs.names

  public_subnets = var.public_subnets

  enable_dns_hostnames    = true
  map_public_ip_on_launch = true

  tags = {
    Name        = "jenkins_vpc"
    Terraform   = "true"
    Environment = "dev"
  }
  public_subnet_tags = {
    Name = "jenkins_public_subnet"
  }
}

module "web_server_sg" {
  source ="terraform-aws-modules/security-group/aws"

  name        = "jenkins-sg"
  description = "Security group for web-server with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "Allow HTTP traffic"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Name = "jenkins_sg"
  }
}

#ec2
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins-server"

  instance_type = var.instance_type
  key_name      = "jenkin-key"
  monitoring    = true
  vpc_security_group_ids = [module.web_server_sg.security_group_id]
  subnet_id     = module.vpc.public_subnets[0]
  ami           = data.aws_ami.example.id
  associate_public_ip_address = true
  availability_zone = data.aws_availability_zones.azs.names[0]
  user_data = file("jenkins-install.sh")

  tags = {
    name = "jenkin-server"
    Terraform   = "true"
    Environment = "dev"
  }
}
provider "aws" {
  region = "ap-south-1"
}



module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "ionginx"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}



# security group for asg 

resource "aws_security_group" "this"{
  tags = {
    Name = "nginx security group"
  }
  name = "nginx security group"
  vpc_id = module.vpc.vpc_id

  ingress{
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress{
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 3.0"
  
  name = "nginx"

  # Launch configuration
  lc_name = "nginx-lc"

  image_id        = "ami-0b44050b2d893d5f7"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.this.id]
  associate_public_ip_address	= "false"
  user_data = "#!/bin/bash\napt update && apt install nginx -y\nsystemctl enable nginx"

  root_block_device = [
    {
      volume_size = "10"
      volume_type = "gp2"
    },
  ]

  # Auto scaling group
  asg_name                  = "nginx-asg"
  vpc_zone_identifier       = [element(module.vpc.private_subnets, 0),element(module.vpc.private_subnets, 1),element(module.vpc.private_subnets, 2)]
  health_check_type         = "EC2"
  min_size                  = 2
  max_size                  = 4
  desired_capacity          = 2
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Environment"
      value               = "dev"
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "ionginx"
      propagate_at_launch = true
    },
  ]


}
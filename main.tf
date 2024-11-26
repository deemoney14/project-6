provider "aws" {
  region = "us-west-1"

}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main_gx_vpc"
  }


}
#public subnet

resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "us-west-1a"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_1a"
  }

}
#privat subnet
resource "aws_subnet" "private_1a" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "us-west-1a"
  cidr_block              = "10.0.16.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private_1a"
  }

}

resource "aws_subnet" "private_2a" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "us-west-1a"
  cidr_block              = "10.0.32.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private_2a"
  }

}

#public subnet

resource "aws_subnet" "public_1c" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "us-west-1c"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_1c"
  }

}
#privat subnet
resource "aws_subnet" "private_1c" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "us-west-1c"
  cidr_block              = "10.0.64.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private_1c"
  }

}

resource "aws_subnet" "private_2c" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "us-west-1c"
  cidr_block              = "10.0.48.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private_2c"
  }

}

#iGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }

}
#nat gateway
resource "aws_eip" "nat_gate1" {

}

resource "aws_eip" "nat_gate2" {

}



resource "aws_nat_gateway" "nat_gateway_ngx" {
  allocation_id = aws_eip.nat_gate1.id
  subnet_id     = aws_subnet.public_1a.id

  tags = {
    Name = "nat_gateway_ngx"
  }

}

resource "aws_nat_gateway" "nat_gateway_ngx1" {
  allocation_id = aws_eip.nat_gate2.id
  subnet_id     = aws_subnet.public_1c.id

  tags = {
    Name = "nat_gateway_ngx1"
  }

}

#Public route

resource "aws_route_table" "route_public1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "route_public1"
  }
}
#Private route


resource "aws_route_table" "route_private1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_ngx.id


  }

  tags = {
    Name = "route_private1"
  }

}

resource "aws_route_table" "route_private2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_ngx1.id
  }

}


#public route assoc

resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.route_public1.id

}

resource "aws_route_table_association" "public_assoc_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.route_public1.id

}

#private route assoc
resource "aws_route_table_association" "private_assoc_1" {
  subnet_id      = aws_subnet.private_1a.id
  route_table_id = aws_route_table.route_private1.id

}

resource "aws_route_table_association" "private_assoc_2" {
  subnet_id      = aws_subnet.private_1c.id
  route_table_id = aws_route_table.route_private2.id
}

#key name
resource "aws_key_pair" "keys" {
  key_name   = "ngx"
  public_key = file("ngx.pem.pub")


}
#EC2

resource "aws_instance" "public_server" {
  ami                         = "ami-04fdea8e25817cd69"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_1a.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  key_name                    = aws_key_pair.keys.key_name

  tags = {
    Name = "public_server"
  }
}

resource "aws_instance" "public_server1" {
  ami                         = "ami-04fdea8e25817cd69"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_1c.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  key_name                    = aws_key_pair.keys.key_name

  tags = {
    Name = "public_server1"
  }
}

#sg
resource "aws_security_group" "public_sg" {
  name        = "public_sg"
  description = "allow HTTP acess over the web"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "public_sg"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


}


#ngx 
resource "aws_launch_template" "ngx_server" {
  name_prefix            = "ngx_server1"
  image_id               = "ami-04fdea8e25817cd69"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name               = aws_key_pair.keys.key_name

  user_data = base64encode(<<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo amazon-linux-extras enable nginx1
    sudo yum install nginx -y
    sudo systemctl start nginx
    sudo systemctl enable nginx
    echo "<h1>Welcome to NGINX</h1>" | sudo tee /usr/share/nginx/html/index.html
  EOF
  )

  tags = {
    Name = "ngx_server"
  }
}


#Auto scaling
resource "aws_autoscaling_group" "ngx_asg" {
  name                      = "ngx-asg"
  max_size                  = 5
  min_size                  = 1
  desired_capacity          = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  vpc_zone_identifier       = [aws_subnet.private_1a.id, aws_subnet.private_1c.id]
  target_group_arns         = [aws_lb_target_group.alb_target_ngx.arn]


  launch_template {
    id      = aws_launch_template.ngx_server.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "ngx-instance"
    propagate_at_launch = true
  }
}


# ngx security 
resource "aws_security_group" "private_sg" {
  name        = "ngx-sg"
  description = "Allow acess through the ALB"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "ngx-sg"
  }

}
resource "aws_security_group_rule" "private_sg_1" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_sg.id
  source_security_group_id = aws_security_group.alb_sg.id

}

resource "aws_security_group_rule" "private_sg_2" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_sg.id
  source_security_group_id = aws_security_group.public_sg.id

}

#alb
resource "aws_lb" "alb_ngx" {
  name               = "albngx"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_1a.id, aws_subnet.public_1c.id]

  tags = {
    Name = "alb_ngx"
  }

}

#alb listener
resource "aws_lb_listener" "alb_ngx_listener" {
  load_balancer_arn = aws_lb.alb_ngx.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_ngx.arn
  }

}

#alb Target
resource "aws_lb_target_group" "alb_target_ngx" {
  name     = "albtargetngx"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }
}


#alb sg
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allow ALB inbound and outbound access"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "alb_sg"
  }

}

output "alb_dns_name" {
  value = aws_lb.alb_ngx.dns_name

}


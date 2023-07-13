# 1. ALB 보안그룹 생성
# 2. 로드 밸런서 생성
# 3. 타겟 그룹 생성
# 4. 리스너
# 5. 리스너 룰


# 1. 오토스케일링 그룹에 생성될 EC2 를 위한 보안그룹 생성
# 2. Auto Scaling 시작 구성 설정
# 3. 오토스케일링그룹 생성


# 1. 웹 인스턴스 보안그룹 생성
resource "aws_security_group" "myWEB_SG" {
    name = "myWEB_SG"
    description = "Allow 80/tcp"
    vpc_id = aws_vpc.project-VPC.id

    # 보안 그룹 내의 리소스로 들어오는 트래픽을 제어 = ingress
    ingress {
        description = "Allow 80/tcp"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    ingress {
        description = "Allow 22/tcp"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    # 외부로 나가는 트래픽 제어 = egress
    egress {
        from_port = 0               # 모든 포트
        to_port = 0                 # 모든 포트
        protocol = "-1"             # 모든 프로토콜
        cidr_blocks = ["0.0.0.0/0"] # 모든 IP 주소
    }
}

# 2. Auto Scaling 시작 구성 설정
resource "aws_launch_configuration" "as_conf" {
    image_id = "ami-0221383823221c3ce"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.myWEB_SG.id]
    key_name = "Web-key"

    
    user_data = templatefile("user-data.sh",{
      db_address = aws_rds_cluster.My-DB-cluster.endpoint,
      db_username = var.db_username,
      db_password = var.db_password,
      db_name = var.db_name
    })
    
    
    
    lifecycle {
      create_before_destroy = false
    }
}

# 3. 오토스케일링그룹 생성
resource "aws_autoscaling_group" "My_ASG" {
    launch_configuration = aws_launch_configuration.as_conf.name
    vpc_zone_identifier = [ 
        aws_subnet.Web-1.id,
        aws_subnet.Web-2.id
     ]
    
    target_group_arns = [aws_lb_target_group.My-ALB-Target-Group.arn]
    health_check_type = "ELB"

    min_size = 2
    max_size = 2

    lifecycle {
      create_before_destroy = true
    }

    tag {
      key = "Name"
      value = "My-ASG"
      propagate_at_launch = true
    }
  
}



# 1. ALB 보안그룹 생성
resource "aws_security_group" "ALB-SG" {
    name = "ALB-SG"
    description = "Allow HTTP"
    vpc_id = aws_vpc.project-VPC.id
    tags = { Name = "ALB-SG "}

    # 인바운드 HTTP 트래픽(80/tcp) 허용
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # 아웃바운드 모든 트래픽 허용
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# 2. 로드 밸런서 생성
resource "aws_lb" "My-ALB" {
    name = "My-ALB"
    internal = false
    load_balancer_type = "application"
    subnets = [ 
        aws_subnet.Public-1.id,
        aws_subnet.Public-2.id
     ]
     security_groups = [aws_security_group.ALB-SG.id]

     tags = { Name = "My-ALB"}
}

# 3. 타겟 그룹
resource "aws_lb_target_group" "My-ALB-Target-Group" {
  
    name = "My-ALB-Target-Group"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.project-VPC.id

    health_check {
      enabled = true
      healthy_threshold = 3
      interval = 5
      matcher = "200"
      path = "/"
      port = "traffic-port"
      protocol = "HTTP"
      timeout = 2
      unhealthy_threshold = 2
    }

    tags = { Name = "My_ALB_Target_Group"}
}

# 4. 리스너
resource "aws_lb_listener" "My_ALB_Listner" {
    load_balancer_arn = aws_lb.My-ALB.arn
    port = "80"
    protocol = "HTTP"

    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.My-ALB-Target-Group.arn
    }
}

# 5. 리스너 룰
resource "aws_lb_listener_rule" "My_ALB_Listner_Rule" {
    listener_arn = aws_lb_listener.My_ALB_Listner.arn
    priority = 100

    condition {
      path_pattern {
        values = ["*"]
      }
    }

    action {
      type = "forward"
      target_group_arn = aws_lb_target_group.My-ALB-Target-Group.arn
    }
}



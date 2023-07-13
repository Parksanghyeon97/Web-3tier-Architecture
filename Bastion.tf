# 1. Bastion host 를 위한 보안 그룹 생성
# 2. Bastion host 인스턴스 생성



# 1. Bastion host 를 위한 보안 그룹 생성
resource "aws_security_group" "Bastion-SG" {
    name = "Bastion-SG"
    description = "Bastion Security Group"
    vpc_id = aws_vpc.project-VPC.id

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "Bastion-SG"
    }
}

# 2. Bastion host 인스턴스 생성
resource "aws_instance" "Bastion-host" {
    ami = "ami-0221383823221c3ce"
    instance_type = "t2.micro"

    key_name = "Bastion-key"            # 기존 키 사용    
    associate_public_ip_address = true  # Public IP 부여

    vpc_security_group_ids = [ aws_security_group.Bastion-SG.id ]

    subnet_id = aws_subnet.Public-1.id

    tags = {
      Name = "Bastion-host"
    }
}
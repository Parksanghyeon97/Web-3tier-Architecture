# data source를 이용해 만든 public subnet 의 id를 받아옴

data "aws_subnets" "my_public_subnet_ids" {
    filter {
      name = "tag:Name"
      values = ["Public-1","Public-2"]
    }
}


# Web 보안 그룹 생성
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

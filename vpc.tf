# Create a VPC
resource "aws_vpc" "project-VPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "project-VPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "Project-IGW" {
    vpc_id = aws_vpc.project-VPC.id

    tags = {
      Name = "Project-IGW"
    }
}

# EIP 주소 할당
resource "aws_eip" "NAT-EIP" {
    vpc = true
    lifecycle {
      create_before_destroy = true
    }
}

# NAT Gateway 생성 - EIP 주소 연결
resource "aws_nat_gateway" "Project-NATGW" {
    allocation_id = aws_eip.NAT-EIP.id
    subnet_id = aws_subnet.Public-2.id
    tags = {
      Name = "Project-NATGW"
    }

    depends_on = [ aws_internet_gateway.Project-IGW ]
}

# Create [ Public-1 ] (ap-northeast-2a)
resource "aws_subnet" "Public-1" {
    vpc_id = aws_vpc.project-VPC.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "ap-northeast-2a"

    tags = {
      Name = "Public-1"
    }
}

# Create [ Web-1 ] (ap-northeast-2a)
resource "aws_subnet" "Web-1" {
    vpc_id = aws_vpc.project-VPC.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-northeast-2a"

    tags = {
      Name = "Web-1"
    }
}

# Create [ DB-1 ] (ap-northeast-2a)
resource "aws_subnet" "DB-1" {
    vpc_id = aws_vpc.project-VPC.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "ap-northeast-2a"

    tags = {
      Name = "DB-1"
    }
}

# Create [ Public-2 ] (ap-northeast-2c)
resource "aws_subnet" "Public-2" {
    vpc_id = aws_vpc.project-VPC.id
    cidr_block = "10.0.10.0/24"
    availability_zone = "ap-northeast-2c"

    tags = {
      Name = "Public-2"
    }
}

# Create [ Web-2 ] (ap-northeast-2c)
resource "aws_subnet" "Web-2" {
    vpc_id = aws_vpc.project-VPC.id
    cidr_block = "10.0.11.0/24"
    availability_zone = "ap-northeast-2c"

    tags = {
      Name = "Web-2"
    }
}

# Create [ DB-2 ] (ap-northeast-2c)
resource "aws_subnet" "DB-2" {
    vpc_id = aws_vpc.project-VPC.id
    cidr_block = "10.0.13.0/24"
    availability_zone = "ap-northeast-2c"

    tags = {
      Name = "DB-2"
    }
}

# [ Public ] 라우팅 테이블 구성
resource "aws_route_table" "Public-route" {
    vpc_id = aws_vpc.project-VPC.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.Project-IGW.id
    }

    tags = {
      Name = "Public-route"
    }
}

#  [ Private ] 라우팅 테이블 구성
resource "aws_route_table" "Private-route" {
    vpc_id = aws_vpc.project-VPC.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.Project-NATGW.id
    }

    tags = {
        Name = "Private-route"
    }

}

# 명시적 서브넷 연결 [ Public-1 <==> Public-route ]
resource "aws_route_table_association" "My_Pub_RT_association_1" {
    subnet_id = aws_subnet.Public-1.id
    route_table_id = aws_route_table.Public-route.id
}

# 명시적 서브넷 연결 [ Public-2 <==> Public-route ]
resource "aws_route_table_association" "My_Pub_RT_association-2" {
    subnet_id = aws_subnet.Public-2.id
    route_table_id = aws_route_table.Public-route.id
}

# 명시적 서브넷 연결 [ Web-1 <==> Private-route ]
resource "aws_route_table_association" "My_Pri_RT_association-Web1" {
    subnet_id = aws_subnet.Web-1.id
    route_table_id = aws_route_table.Private-route.id
}

# 명시적 서브넷 연결 [ Web-2 <==> Private-route ]
resource "aws_route_table_association" "My_Pri_RT_association-Web2" {
    subnet_id = aws_subnet.Web-2.id
    route_table_id = aws_route_table.Private-route.id
}

# 명시적 서브넷 연결 [ DB-1 <==> Private-route ]
resource "aws_route_table_association" "My_Pri_RT_association-DB1" {
    subnet_id = aws_subnet.DB-1.id
    route_table_id = aws_route_table.Private-route.id
}

# 명시적 서브넷 연결 [ DB-2 <==> Private-route ]
resource "aws_route_table_association" "My_Pri_RT_association-DB2" {
    subnet_id = aws_subnet.DB-2.id
    route_table_id = aws_route_table.Private-route.id
}

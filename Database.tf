## 데이터 베이스 구성 ##

# 1. DB 서브넷 그룹 생성
# 2. DB 보안그룹 생성
# 3. RDS DB 클러스터 생성
# 4. RDS cluster_instance 생성


# 1. DB 서브넷 그룹 생성
resource "aws_db_subnet_group" "My-DB-Subnet-Group" {
    name        = "my-db-subnet-group"
    subnet_ids = [ 
        aws_subnet.DB-1.id,
        aws_subnet.DB-2.id
     ]
    
    tags = {
        Name = "My DB Subnet Group"
    }
}


# 2. DB 보안그룹 생성
resource "aws_security_group" "My-DB-SG" {
    name = "My-DB-SG"
    description = "Allow 3306/tcp"
    vpc_id = aws_vpc.project-VPC.id

    ingress {
        description = "Allow 3306/tcp"
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    tags = {
      Name = "My-DB-SG"
    }
}

# 3. RDS DB 클러스터 생성
resource "aws_rds_cluster" "My-DB-cluster" {
    cluster_identifier = "my-aurora-cluster"
    engine = "aurora-mysql"

    availability_zones = [ 
        var.availability_zone1,
        var.availability_zone2
     ]
    
    db_subnet_group_name = aws_db_subnet_group.My-DB-Subnet-Group.name

    database_name = var.db_name
    master_username = var.db_username
    master_password = var.db_password

    vpc_security_group_ids = [ aws_security_group.My-DB-SG.id ]

    skip_final_snapshot = true
}

resource "aws_rds_cluster_instance" "cluster_instances1" {
    identifier = "aurora-cluster-instance-1"
    cluster_identifier = aws_rds_cluster.My-DB-cluster.id
    instance_class = "db.t2.small"
    engine = aws_rds_cluster.My-DB-cluster.engine
    engine_version = aws_rds_cluster.My-DB-cluster.engine_version
}

resource "aws_rds_cluster_instance" "cluster_instances2" {
    identifier = "aurora-cluster-instance-2"
    cluster_identifier = aws_rds_cluster.My-DB-cluster.id
    instance_class = "db.t2.small"
    engine = aws_rds_cluster.My-DB-cluster.engine
    engine_version = aws_rds_cluster.My-DB-cluster.engine_version
}

# RDS 서브넷 그룹 생성
resource "aws_db_subnet_group" "MSA_rds_subnet_group" {
  name       = "msa_rds_subnet_group"
  subnet_ids = [aws_subnet.MSA_pri_subnet_2a.id, aws_subnet.MSA_pri_subnet_2c.id]

  tags = {
    Name = "MSA_rds_subnet_group"
  }
}

# MariaDB Parameter Group 설정
resource "aws_db_parameter_group" "MSA_mariadb_parameter_group" {
  name        = "msa-mariadb-parameter-group"
  family      = "mariadb10.11"
  description = "Custom parameter group for MariaDB"

  parameter {
    name  = "max_connections"
    value = "150"
  }

  parameter {
    name  = "time_zone"
    value = "Asia/Seoul"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_filesystem"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_results"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_connection"
    value = "utf8mb4_unicode_ci"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }

  parameter {
    name  = "binlog_format"
    value = "ROW"
  }
}

# RDS 인스턴스 생성
resource "aws_db_instance" "MSA_mariadb_rds" {
  identifier_prefix      = "msa-mariadb-rds"
  allocated_storage      = 10
  engine                 = "mariadb"
  engine_version         = "10.11.8"
  instance_class         = "db.t3.micro"
  db_name                = "MSA_mariadb_rds"
  username               = "MSA_User"
  password               = var.rds_password
  parameter_group_name   = aws_db_parameter_group.MSA_mariadb_parameter_group.name
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.MSA_rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.MSA_sg_rds.id]

  tags = {
    Name = "MSA_mariadb_rds"
  }
}

# 초기 SQL 실행 (UsersService, BoardsService DB 및 테이블 생성)
resource "null_resource" "init_rds_sql" {
  depends_on = [aws_instance.MSA_pub_ec2_bastion_2a, aws_db_instance.MSA_mariadb_rds]

  provisioner "file" {
    content = templatefile("${path.module}/scripts/init_rds.sh.tpl", {
      DB_HOST      = aws_db_instance.MSA_mariadb_rds.address,
      DB_USER      = var.rds_username, 
      DB_PW        = var.rds_password,
      rds_password = var.rds_password,
      rds_endpoint = aws_db_instance.MSA_mariadb_rds.address
    })
    destination = "/tmp/init_rds.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/init_rds.sh",
      "bash /tmp/init_rds.sh"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = var.private_key
    host        = aws_instance.MSA_pub_ec2_bastion_2a.public_ip
  }
}

# 변수 선언
variable "rds_password" {
  description = "Password for the MariaDB RDS root user"
  type        = string
  sensitive   = true
}

variable "private_key" {
  description = "SSH private key to connect to bastion"
  type        = string
  sensitive   = true
}

variable "rds_username" {
  description = "Database admin username"
  type        = string
  default     = "MSA_User"  # 또는 원하는 기본값
}




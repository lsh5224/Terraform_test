#!/bin/bash
set -e  # 한 줄이라도 실패하면 즉시 종료해 Terraform이 에러를 잡도록

# 1. MySQL 클라이언트 설치
if ! command -v mysql >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y mariadb-client
fi

DB_HOST="$${rds_endpoint}"
DB_PW="$${rds_password}"
DB_USER="MSA_User"

# 2. 초기 스키마 파일 생성
cat <<'EOF' >/tmp/init.sql
CREATE USER IF NOT EXISTS 'MSA_User'@'%' IDENTIFIED BY '$${DB_PW}';
GRANT ALL PRIVILEGES ON UsersService.*  TO 'MSA_User'@'%';
GRANT ALL PRIVILEGES ON BoardsService.* TO 'MSA_User'@'%';
FLUSH PRIVILEGES;

CREATE DATABASE IF NOT EXISTS UsersService
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

CREATE DATABASE IF NOT EXISTS BoardsService
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS UsersService.users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  user_id VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL UNIQUE,
  password VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  email VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS BoardsService.boards (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  content TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  author_id INT NOT NULL,
  CONSTRAINT fk_author FOREIGN KEY (author_id)
    REFERENCES UsersService.users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


EOF

# 3. SQL 적용
mysql -h ${DB_HOST} -P 3306 -u ${DB_USER} -p${DB_PW} < /tmp/init.sql
echo "✅  RDS 초기화 완료"

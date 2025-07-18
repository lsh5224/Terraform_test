data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow Jenkins and SSH"
  vpc_id      = aws_vpc.MSA_vpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Jenkins 접속용
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # SSH 접속용
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-sg"
  }
}

resource "aws_instance" "jenkins" {
  ami                    = "ami-056a29f2eddc40520" # Ubuntu 또는 Amazon Linux
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.MSA_pub_subnet_2c.id
  associate_public_ip_address = true
  key_name               = "ja-01"
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  tags = {
    Name = "jenkins"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y software-properties-common
              apt install -y openjdk-17-jdk

              # Java 대체 경로 등록 및 설정 (자동으로 넘기기 위해 echo 사용)
              echo | update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-17-openjdk-amd64/bin/java 1
              echo | update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java

              # 확인용 로그 남기기
              java -version > /tmp/java_version_check.log

              # Docker 설치
              apt install -y docker.io
              usermod -aG docker ubuntu
              systemctl enable docker
              systemctl start docker

              # Jenkins 설치
              curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
              echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/ | tee /etc/apt/sources.list.d/jenkins.list > /dev/null

              apt update -y
              apt install -y jenkins
              systemctl daemon-reexec
              systemctl daemon-reload
              systemctl enable jenkins
              systemctl restart jenkins
              EOF

}

resource "aws_iam_role" "jenkins_ecr_role" {
  name = "jenkins-ecr-access"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_policy" "jenkins_ecr_policy" {
  name   = "jenkins-ecr-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:BatchGetImage"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_ecr_attachment" {
  role       = aws_iam_role.jenkins_ecr_role.name
  policy_arn = aws_iam_policy.jenkins_ecr_policy.arn
}


variable "ecr_repositories" {
  default = [
    "backend-boards",
    "backend-user",
    "frontend"
  ]
}

variable "terraform_values_repo" {
  default = "https://github.com/lsh5224/Terraform_test.git"
}









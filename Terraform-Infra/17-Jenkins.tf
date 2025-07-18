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
                set -e

                apt update -y
                apt install -y openjdk-17-jdk docker.io curl gnupg2

                usermod -aG docker ubuntu
                systemctl enable docker
                systemctl start docker

                # Jenkins 설치
                curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
                echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/ > /etc/apt/sources.list.d/jenkins.list
                apt update -y
                apt install -y jenkins

                # Groovy 자동 설정
                mkdir -p /var/lib/jenkins/init.groovy.d
                cat <<'EOT' > /var/lib/jenkins/init.groovy.d/basic-security.groovy
                import jenkins.model.*
                import hudson.security.*
                def instance = Jenkins.getInstance()
                def hudsonRealm = new HudsonPrivateSecurityRealm(false)
                hudsonRealm.createAccount("admin", "admin")
                instance.setSecurityRealm(hudsonRealm)
                def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
                strategy.setAllowAnonymousRead(false)
                instance.setAuthorizationStrategy(strategy)
                instance.save()
                EOT

                # Jenkins 초기 마법사 스킵
                echo "2.0" > /var/lib/jenkins/jenkins.install.UpgradeWizard.state
                echo "2.519" > /var/lib/jenkins/jenkins.install.InstallUtil.lastExecVersion

                # Jenkins 권한 조정
                chown -R jenkins:jenkins /var/lib/jenkins

                # Jenkins 시작
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









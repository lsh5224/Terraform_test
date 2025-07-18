resource "aws_instance" "jenkins" {
  ami                    = "ami-xxxxxxxxxxxxxxxxx" # Ubuntu 또는 Amazon Linux
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.public_1a.id
  associate_public_ip_address = true
  key_name               = "ja-01"
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  tags = {
    Name = "jenkins"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y docker.io
              sudo usermod -aG docker ubuntu
              sudo systemctl enable docker
              sudo systemctl start docker

              # Jenkins 설치
              sudo apt install -y openjdk-11-jdk
              wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
              sudo sh -c 'echo deb https://pkg.jenkins.io/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
              sudo apt update -y
              sudo apt install -y jenkins
              sudo systemctl enable jenkins
              sudo systemctl start jenkins
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


pipeline {
    agent any
    environment {
        AWS_REGION = "ap-northeast-2"
        REPO = "https://github.com/lsh5224/Terraform_test.git"
    }
    stages {
        stage('Clone Repo') {
            steps {
                sh 'git clone $REPO'
            }
        }
        stage('Fetch ECR Tags') {
            steps {
                script {
                    def repos = ["frontend", "backend-user", "backend-boards"]
                    def latestTags = [:]
                    for (repo in repos) {
                        def tags = sh(script: "aws ecr list-images --repository-name ${repo} --query 'imageIds[*].imageTag' --output text", returnStdout: true).trim().split()
                        latestTags[repo] = tags.sort().last()
                    }
                    writeFile file: 'Terraform_test/values.yaml', text: updateYamlWithTags(latestTags)
                }
            }
        }
        stage('Git Push') {
            steps {
                dir('Terraform_test') {
                    sh '''
                    git config --global user.email "jenkins@ci"
                    git config --global user.name "Jenkins CI"
                    git add .
                    git commit -m "Update image tags"
                    git push origin main
                    '''
                }
            }
        }
    }
}

def updateYamlWithTags(tags) {
    return """
backend:
  boards:
    tag: "${tags["backend-boards"]}"
  user:
    tag: "${tags["backend-user"]}"

frontend:
  tag: "${tags["frontend"]}"
"""
}

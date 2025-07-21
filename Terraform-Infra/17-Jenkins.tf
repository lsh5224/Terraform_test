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
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

data "template_file" "jenkins_user_data" {
  template = file("${path.module}/scripts/init_jenkins.sh.tpl")
  vars = {
    public_ip = "REPLACE_ME_WITH_ACTUAL_PUBLIC_IP"
  }
}

resource "aws_instance" "jenkins" {
  ami                         = "ami-056a29f2eddc40520"
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.MSA_pub_subnet_2a.id
  associate_public_ip_address = true
  key_name                    = "ja-01"
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]

  user_data = data.template_file.jenkins_user_data.rendered

  tags = {
    Name = "jenkins"
  }
}

output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}

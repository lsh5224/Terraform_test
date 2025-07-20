resource "aws_instance" "jenkins" {
  ami                    = "ami-056a29f2eddc40520"
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.MSA_pub_subnet_2a.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name               = "ja-01"

  user_data = file("${path.module}/scripts/init_jenkins.sh")

  tags = {
    Name = "Jenkins-Server"
  }
}

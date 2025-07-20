#!/bin/bash
set -e






# 최신 Java 설치 (Temurin OpenJDK 21 기준)
sudo apt update -y
sudo apt install -y wget gnupg curl unzip

# Temurin GPG 키 및 repo 추가
wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo gpg --dearmor -o /usr/share/keyrings/adoptium.gpg
echo "deb [signed-by=/usr/share/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/adoptium.list

sudo apt update -y
sudo apt install -y temurin-21-jdk

# Jenkins 설치
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update -y
sudo apt install -y jenkins

# Jenkins 시작
sudo systemctl enable jenkins
sudo systemctl start jenkins

# admin 비밀번호를 "admin"으로 강제 설정
JENKINS_HOME="/var/lib/jenkins"

# Jenkins 실행 전 비밀번호 설정을 우회
sudo systemctl stop jenkins
sudo mkdir -p $JENKINS_HOME/init.groovy.d

cat <<EOF | sudo tee $JENKINS_HOME/init.groovy.d/basic-security.groovy
#!groovy

import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()

println "--> creating local user 'admin'"
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("admin", "admin")
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)
instance.save()
EOF

sudo chown -R jenkins:jenkins $JENKINS_HOME
sudo systemctl start jenkins

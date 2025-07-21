#!/bin/bash
set -e

echo "127.0.1.1 jenkins" >> /etc/hosts
rm -f /etc/resolv.conf
echo "nameserver 8.8.8.8" > /etc/resolv.conf

apt update -y
apt install -y openjdk-17-jdk docker.io curl gnupg2

usermod -aG docker ubuntu
systemctl enable docker
systemctl start docker

curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/ > /etc/apt/sources.list.d/jenkins.list

apt update -y
apt install -y jenkins

systemctl disable jenkins
systemctl stop jenkins || true

mkdir -p /var/lib/jenkins/init.groovy.d
cat <<'EOT' > /var/lib/jenkins/init.groovy.d/basic-security.groovy
import jenkins.model.*
import hudson.security.*
import jenkins.model.JenkinsLocationConfiguration

def instance = Jenkins.getInstance()
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("admin", "admin")
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

JenkinsLocationConfiguration.get().setUrl("http://${public_ip}:8080/")
instance.save()
EOT

echo "2.0" > /var/lib/jenkins/jenkins.install.UpgradeWizard.state
echo "2.519" > /var/lib/jenkins/jenkins.install.InstallUtil.lastExecVersion

chown -R jenkins:jenkins /var/lib/jenkins

systemctl enable jenkins
systemctl start jenkins

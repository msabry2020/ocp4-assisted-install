sudo dnf install -y epel-release
sudo dnf install -y ansible
sudo dnf install -y wget unzip
wget -P /tmp https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip
unzip /tmp/terraform_1.5.7_linux_amd64.zip -d /tmp
sudo cp /tmp/terraform /usr/local/bin/
terraform --version
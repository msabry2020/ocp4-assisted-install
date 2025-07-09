# ocp4-assisted-install
gcloud init
gcloud compute instances create ocp-kvm \
    --zone=us-central1-c \
    --min-cpu-platform="Intel Haswell" \
    --machine-type=custom-8-153600-ext \
    --create-disk=auto-delete=yes,boot=yes,device-name=ocp-kvm,image=projects/centos-cloud/global/images/centos-stream-9-v20250610,mode=rw,size=200,type=pd-balanced \
    --shielded-integrity-monitoring \
    --enable-nested-virtualization


sudo sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/*.repo
sudo sed -i s/^#.*baseurl=http/baseurl=http/g /etc/yum.repos.d/*.repo
sudo sed -i s/^mirrorlist=http/#mirrorlist=http/g /etc/yum.repos.d/*.repo
sudo sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

sudo dnf -y install git
git clone https://github.com/msabry2020/ocp4-assisted-install.git
cd ocp4-assisted-install
sh pre.sh
ssh-keygen
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
ansible-playbook -i ansible/inventory ansible/playbook.yml
sudo passwd $USER
sudo usermod -aG libvirt $USER
cd /var/lib/libvirt/images
sudo wget -O ocp_discovery.iso 'https://api.openshift.com/api/assisted-images...........'
sudo chown qemu:qemu ocp_discovery.iso
sudo echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
sudo sysctl -p
cd terraform
terraform init
terraform apply
sudo wget -O /tmp/openshift-client-linux-amd64-rhel8-4.17.16.tar.gz 'https://access.cdn.redhat.com/content/origin/files/sha256/ec/ec7d980ef45025c0ecdffb7c5f6e759b635a8ff9eac427cb63950174ded37f59/openshift-client-linux-amd64-rhel8-4.17.16.tar.gz?user=da720d4786077adbb520911fefbf25ed&_auth_=1739721519_02aaab8495ef59a48f791ea17b0518e7'
sudo tar xvf /tmp/openshift-client-linux-amd64-rhel8-4.17.16.tar.gz -C /usr/bin
echo 'export KUBECONFIG=/home/eng_muhammedsabry/kubeconfig' >> ~/.bashrc
source ~/.bashrc
sudo -i
cat <<EOF >> /etc/hosts
192.168.122.99      api.gcp.lab.cloud
192.168.122.100	    oauth-openshift.apps.gcp.lab.cloud
192.168.122.100     console-openshift-console.apps.gcp.lab.cloud
192.168.122.100     grafana-openshift-monitoring.apps.gcp.lab.cloud
192.168.122.100     thanos-querier-openshift-monitoring.apps.gcp.lab.cloud
192.168.122.100     prometheus-k8s-openshift-monitoring.apps.gcp.lab.cloud
192.168.122.100     alertmanager-main-openshift-monitoring.apps.gcp.lab.cloud
EOF

sudo dnf install haproxy
sudo cp haproxy.cfg /etc/haproxy/haproxy.cfg
sudo setenforce 0
sudo systemctl enable haproxy --now

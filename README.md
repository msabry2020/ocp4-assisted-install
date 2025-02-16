# ocp4-assisted-install
gcloud init
gcloud compute instances create ocp-kvm \
    --project=openshift-450711 \
    --zone=us-central1-f \
    --min-cpu-platform="Intel Haswell" \
    --machine-type=n1-highmem-8 \
    --metadata=ssh-keys=eng_muhammedsabry:ssh-ed25519\ AAAAC3NzaC1lZDI1NTE5AAAAIJGYzvHIIjCZn/tm8hUT7kkwChE7wh/ZW9IyyEHGxCOQ\ eng_muhammedsabry@ocp-kvm \
    --create-disk=auto-delete=yes,boot=yes,device-name=instance-20250213-110808,image=projects/centos-cloud/global/images/centos-stream-8-v20240515,mode=rw,size=200,type=pd-balanced \
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
cat /home/eng_muhammedsabry/.ssh/id_rsa.pub >> /home/eng_muhammedsabry/.ssh/authorized_keys
ansible-playbook -i ansible/inventory ansible/playbook.yml
sudo passwd eng_muhammedsabry
cd /var/lib/libvirt/images
sudo wget -O ocp_discovery.iso 'https://api.openshift.com/api/assisted-images...........'
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
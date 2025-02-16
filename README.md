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
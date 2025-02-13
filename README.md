# ocp4-assisted-install
gcloud init
gcloud compute instances create ocp-kvm \
    --project=openshift-450711 \
    --zone=us-central1-f \
    --machine-type=n2d-highmem-8 \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
    --metadata=ssh-keys=eng_muhammedsabry:ssh-ed25519\ AAAAC3NzaC1lZDI1NTE5AAAAIJGYzvHIIjCZn/tm8hUT7kkwChE7wh/ZW9IyyEHGxCOQ\ eng_muhammedsabry@ocp-kvm \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account=989072574072-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append \
    --create-disk=auto-delete=yes,boot=yes,device-name=instance-20250213-110808,image=projects/centos-cloud/global/images/centos-stream-9-v20250123,mode=rw,size=200,type=pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=goog-ec-src=vm_add-gcloud \
    --reservation-affinity=any

sudo dnf -y install git
git clone https://github.com/msabry2020/ocp4-assisted-install.git
cd ocp4-assisted-install
sh pre.sh
ssh-keygen
cat /home/eng_muhammedsabry/.ssh/id_rsa.pub >> /home/eng_muhammedsabry/.ssh/authorized_keys
ansible-playbook -i ansible/inventory ansible/playbook.yml
sudo passwd eng_muhammedsabry
cd terraform
terraform init
terraform apply
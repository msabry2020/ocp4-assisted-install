sudo dnf install tigervnc-server
vncpasswd
sudo vim /etc/tigervnc/vncserver.users 
sudo systemctl enable --now vncserver@:1
sudo firewall-cmd --add-port=5901/tcp --permanent
sudo firewall-cmd --reload

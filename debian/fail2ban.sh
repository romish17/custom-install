sudo apt install -y fail2ban iptables
sudo cp /etc/fail2ban/jail.{conf,local}
sudo sed -i 's/backend = auto/backend = systemd/' /etc/fail2ban/jail.local
sudo systemctl restart fail2ban.service
systemctl status fail2ban.service
sleep 2
sudo fail2ban-client status sshd

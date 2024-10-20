#!/bin/bash

# Clean apt cache
sudo apt clean

# Install packages
sudo apt update
sudo apt install -y ntp

# Disable NTP synchronization
sudo timedatectl set-ntp false
sudo timedatectl set-local-rtc 0

# Create and execute command.sh
echo "shutdown -r 22:15 &" > /root/command.sh
echo "NOW=\$(date --set='20230827 18:30:30')" >> /root/command.sh
echo "hwclock --set --date '20230827 18:30:19'" >> /root/command.sh
chmod +x /root/command.sh
/root/command.sh

# Configure rc.local for startup commands
echo "#!/bin/bash" | sudo tee /etc/rc.local
echo "sh /root/command.sh" | sudo tee -a /etc/rc.local
sudo chmod +x /etc/rc.local

# Set file permissions (Adjust paths if needed)
sudo chmod 444 /usr/local/cpanel/cpanel.lisc
sudo chmod 000 /usr/local/cpanel/cpkeyclt
sudo chmod 440 /usr/local/cpanel/scripts/upcp
sudo chmod 440 /usr/local/cpanel/scripts/upcp-running
sudo chmod 440 /usr/local/cpanel/scripts/upcp.static
sudo chmod 440 /usr/local/cpanel/scripts/updatenow.static
sudo chmod 440 /usr/local/cpanel/scripts/updatenow

# Configure UFW (Uncomplicated Firewall) rules
sudo ufw deny from 0.0.0.0
sudo ufw allow 9011/tcp
sudo ufw allow 53/tcp
sudo ufw allow 443/tcp
sudo ufw allow 80/tcp
sudo ufw allow 2087/tcp
sudo ufw allow 2083/tcp

# Enable UFW if it's not already enabled
sudo ufw enable

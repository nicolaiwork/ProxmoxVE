#!/usr/bin/env bash

# Copyright (c) 2021-2025 community-scripts ORG
# Author: tteck (tteckster)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://evan-buss.github.io/openbooks/

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y curl
msg_ok "Installed Dependencies"

msg_info "Installing OpenBooks"
RELEASE=$(curl -fsSL https://api.github.com/repos/evan-buss/openbooks/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
echo "${RELEASE}" >"/opt/${APPLICATION}_version.txt"

# Create directory for OpenBooks
mkdir -p /opt/openbooks

# Download the binary directly
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
  curl -fsSL "https://github.com/evan-buss/openbooks/releases/download/v${RELEASE}/openbooks_linux" -o /opt/openbooks/openbooks
elif [[ "$ARCH" == "aarch64" ]]; then
  curl -fsSL "https://github.com/evan-buss/openbooks/releases/download/v${RELEASE}/openbooks_linux_arm" -o /opt/openbooks/openbooks
else
  msg_error "Unsupported architecture: $ARCH"
  exit 1
fi

chmod +x /opt/openbooks/openbooks
msg_ok "Installed OpenBooks"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/openbooks.service
[Unit]
Description=OpenBooks Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/openbooks
ExecStart=/opt/openbooks/openbooks --name openbooks --port 8080
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl enable -q --now openbooks
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned" 

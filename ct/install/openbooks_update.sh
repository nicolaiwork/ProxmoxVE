#!/usr/bin/env bash
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://evan-buss.github.io/openbooks/

msg_info "Updating OpenBooks"
cd /opt/openbooks
git pull
pip3 install -r requirements.txt --upgrade
systemctl restart openbooks
msg_ok "Updated OpenBooks" 

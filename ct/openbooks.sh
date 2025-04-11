#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2025 tteck
# Author: tteck (tteckster)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://evan-buss.github.io/openbooks/

APP="OpenBooks"
var_tags="${var_tags:-books}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-512}"
var_disk="${var_disk:-2}"
var_os="${var_os:-debian}"
var_version="${var_version:-12}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
    header_info
    check_container_storage
    check_container_resources
    if [[ ! -d /opt/openbooks ]]; then
        msg_error "No ${APP} Installation Found!"
        exit
    fi
    msg_info "Updating ${APP}"
    cd /opt/openbooks
    git pull
    msg_ok "Updated $APP"
    exit
}

start
build_container
description

msg_info "Setting up Container OS"
apt-get update &>/dev/null
apt-get -y upgrade &>/dev/null
msg_ok "Set up Container OS"

msg_info "Installing Dependencies"
apt-get install -y curl git python3 python3-pip &>/dev/null
msg_ok "Installed Dependencies"

msg_info "Creating OpenBooks Directory"
mkdir -p /opt/openbooks
cd /opt/openbooks
msg_ok "Created OpenBooks Directory"

msg_info "Downloading OpenBooks"
git clone https://github.com/evan-buss/openbooks.git . &>/dev/null
msg_ok "Downloaded OpenBooks"

msg_info "Installing Python Dependencies"
pip3 install -r requirements.txt &>/dev/null
msg_ok "Installed Python Dependencies"

msg_info "Creating Systemd Service"
cat <<EOF > /etc/systemd/system/openbooks.service
[Unit]
Description=OpenBooks Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/openbooks
ExecStart=/usr/bin/python3 /opt/openbooks/openbooks.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now openbooks &>/dev/null
msg_ok "Created Systemd Service"

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8080${CL}" 

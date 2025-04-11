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
    bash -c "$(curl -fsSL https://github.com/evan-buss/openbooks/raw/main/install/openbooks_update.sh)" -s --lxc
    msg_ok "Updated $APP"
    exit
}

start
build_container
description

bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/install/openbooks-install.sh)" -s --lxc

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8080${CL}" 

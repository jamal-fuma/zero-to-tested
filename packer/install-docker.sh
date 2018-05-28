#!/bin/sh

REPO_HOSTNAME="download.docker.com"
REPO_REQUEST_PATH="/linux/ubuntu"
REPO_BASE_URL="https://${REPO_HOSTNAME}${REPO_REQUEST_PATH}"
DOCKER_INSTALL_SH_URL="https://get.docker.com"

REPO_SIGNING_KEY_URL="${REPO_BASE_URL}/gpg"
REPO_APT_SOURCES_URL="deb [arch=amd64] ${REPO_BASE_URL} $(lsb_release -cs) stable"

REPO_APT_TOOLS_DEBS="apt-transport-https ca-certificates curl software-properties-common"
OBSOLETE_DEBS="docker docker-engine docker.io"
DOCKER_DEBS="docker-ce git"

CURL=curl
APT_GET=${APT_GET:-"/usr/bin/apt-get"}
ADD_APT_REPO=${ADD_APT_REPO:-"/usr/bin/add-apt-repository"}
APT_KEY=apt-key
SUDO=sudo
SH=/bin/sh

apt_get_install(){
    sudo "${APT_GET}" install -y $@
}

apt_get_update(){
    sudo "${APT_GET}" update
}

apt_get_purge(){
    sudo "${APT_GET}" remove --purge -y $@
}

curl_fetch_to_stdout(){
    local url="${1}";
    "${CURL}" -fsSL "${url}"
}

curl_fetch_repo_key(){
    curl_fetch_to_stdout "${REPO_SIGNING_KEY_URL}"
}

curl_fetch_docker_install_sh(){
    curl_fetch_to_stdout "${DOCKER_INSTALL_SH_URL}"
}

install_apt_tools(){
    apt_get_install ${REPO_APT_TOOLS_DEBS}
}

install_custom_repo(){
    curl_fetch_repo_key | sudo apt-key add -;
    sudo  "${ADD_APT_REPO}" "${REPO_APT_SOURCES_URL}"
    apt_get_update;
}

install_kernel_extra_headers(){
    apt_get_install "linux-image-extra-$(uname -r)" "linux-image-extra-virtual"
}

install_docker_like_a_hipster(){
    apt_get_purge ${OBSOLETE_DEBS}
    apt_get_install ${DOCKER_DEBS}
}

install_apt_tools
install_custom_repo
install_kernel_extra_headers
install_docker_like_a_hipster

cat /dev/null > /var/log/upstart/docker.log

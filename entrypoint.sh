#!/usr/bin/env bash

# === CONFIGURATION ===
# Set your UUID and WebSocket paths
UUID='9a35d517-f2c3-48f1-bf74-2c5f3844aa07'
VMESS_WSPATH='/vmess'
VLESS_WSPATH='/vless'
TROJAN_WSPATH='/trojan'
SS_WSPATH='/shadowsocks'

# Optional: Nezha Probe Settings (leave blank if unused)
NEZHA_SERVER=''
NEZHA_PORT=''
NEZHA_KEY=''

# === UPDATE CONFIGS ===
# Replace placeholders in config.json and nginx.conf
sed -i "s#UUID#${UUID}#g" /etc/v2ray/config.json
sed -i "s#VMESS_WSPATH#${VMESS_WSPATH}#g" /etc/v2ray/config.json
sed -i "s#VLESS_WSPATH#${VLESS_WSPATH}#g" /etc/v2ray/config.json
sed -i "s#TROJAN_WSPATH#${TROJAN_WSPATH}#g" /etc/v2ray/config.json
sed -i "s#SS_WSPATH#${SS_WSPATH}#g" /etc/v2ray/config.json

sed -i "s#VMESS_WSPATH#${VMESS_WSPATH}#g" /etc/nginx/nginx.conf
sed -i "s#VLESS_WSPATH#${VLESS_WSPATH}#g" /etc/nginx/nginx.conf
sed -i "s#TROJAN_WSPATH#${TROJAN_WSPATH}#g" /etc/nginx/nginx.conf
sed -i "s#SS_WSPATH#${SS_WSPATH}#g" /etc/nginx/nginx.conf

# === RANDOMIZE XRAY BINARY NAME ===
RANDOM_BIN=$(tr -dc 'a-z0-9' </dev/urandom | head -c 8)
mv /usr/local/bin/xray "/usr/local/bin/${RANDOM_BIN}"

# Download latest geoip and geosite data
wget -q -O /etc/v2ray/geoip.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat
wget -q -O /etc/v2ray/geosite.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat

# === STATIC WEB CONTENT ===
# Replace default nginx www content with camouflage site
rm -rf /usr/share/nginx/html/*
wget -q https://gitlab.com/Misaka-blog/xray-paas/-/raw/main/mikutap.zip -O /tmp/mikutap.zip
unzip -o /tmp/mikutap.zip -d /usr/share/nginx/html/
rm -f /tmp/mikutap.zip

# === OPTIONAL: Install Nezha Probe ===
if [[ -n "${NEZHA_SERVER}" && -n "${NEZHA_PORT}" && -n "${NEZHA_KEY}" ]]; then
    wget -qO nezha.sh https://raw.githubusercontent.com/naiba/nezha/master/script/install.sh
    chmod +x nezha.sh
    ./nezha.sh install_agent "${NEZHA_SERVER}" "${NEZHA_PORT}" "${NEZHA_KEY}"
fi

# === START SERVICES ===
# Start Nginx (reverse proxy)
nginx

# Run Xray with updated config
"/usr/local/bin/${RANDOM_BIN}" -config /etc/v2ray/config.json

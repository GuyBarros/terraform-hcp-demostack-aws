#!/usr/bin/env bash
echo "==> Consul (client)"

echo "==> Consul (server)"
if [ ${enterprise} == 0 ]
then
echo "--> Fetching OSS binaries"
install_from_url "consul" "${consul_url}"
else
echo "--> Fetching enterprise binaries"
install_from_url "consul" "${consul_ent_url}"
fi

echo "--> Writing configuration"
sudo mkdir -p /mnt/consul
sudo mkdir -p /etc/consul.d
echo ${hcp_ca_file} | base64 --decode > /etc/consul.d/ca.pem
echo ${hcp_config_file}| base64 --decode > /etc/consul.d/config.json
sudo tee /etc/consul.d/client_acl.json > /dev/null <<EOF
{
  "acl": {
    "tokens": {
      "agent": "${hcp_acl_token}"
    }
  }
}
EOF

sudo tee /etc/consul.d/additional_config.json > /dev/null <<EOF
{
"advertise_addr": "$(private_ip)",
"advertise_addr_wan": "$(public_ip)",
"bind_addr": "0.0.0.0",
"client_addr": "0.0.0.0",
 "node_name": "${node_name}",
"ports": {
    "http": 8500,
    "https": 8501,
    "grpc": 8502
  },
"data_dir": "/mnt/consul"
}
EOF

echo "--> Writing profile"
sudo tee /etc/profile.d/consul.sh > /dev/null <<EOF
alias conslu="consul"
alias ocnsul="consul"
EOF
source /etc/profile.d/consul.sh





echo "--> Making consul.d world-writable..."
sudo chmod 0777 /etc/consul.d/

echo "--> Generating systemd configuration"
sudo tee /etc/systemd/system/consul.service > /dev/null <<EOF
[Unit]
Description=Consul
Documentation=https://www.consul.io/docs/
Requires=network-online.target
After=network-online.target

[Service]
WorkingDirectory=/etc/consul.d
Restart=on-failure
ExecStart=/usr/local/bin/consul agent -config-dir="/etc/consul.d"
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable consul
sudo systemctl start consul

#  echo "--> Installing dnsmasq"
#  apt install -y dnsmasq
#  sudo tee /etc/dnsmasq.d/10-consul > /dev/null <<EOF
#  server=/consul/127.0.0.1#8600
#  no-poll
#  server=8.8.8.8
#  server=8.8.4.4
#  cache-size=0
#  EOF
#  sudo systemctl enable dnsmasq
#  sudo systemctl restart dnsmasq

echo "--> setting up resolv.conf"
##################################
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

mkdir /etc/systemd/resolved.conf.d
touch /etc/systemd/resolved.conf.d/forward-consul-domains.conf

IPV4=$(ec2metadata --local-ipv4)

printf "[Resolve]\nDNS=127.0.0.1\nDomains=~consul\n" > /etc/systemd/resolved.conf.d/forward-consul-domains.conf

sudo iptables -t nat -A OUTPUT -d localhost -p udp -m udp --dport 53 -j REDIRECT --to-ports 8600
sudo iptables -t nat -A OUTPUT -d localhost -p tcp -m tcp --dport 53 -j REDIRECT --to-ports 8600

systemctl daemon-reload
systemctl restart systemd-resolved
##################################

echo "==> Consul is done!"

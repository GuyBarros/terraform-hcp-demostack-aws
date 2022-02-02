#!/usr/bin/env bash


echo "--> Writing configuration"
sudo mkdir -p /mnt/consul
sudo mkdir -p /etc/consul.d
echo ${hcp_ca_file} | base64 --decode > /etc/consul.d/ca.pem
echo ${hcp_config_file}| base64 --decode > /etc/consul.d/config.json

sed -i 's/.\/ca.pem/\/etc\/consul.d\/ca.pem/' /etc/consul.d/config.json

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
WorkingDirectory=/etc/consul.d/
Restart=on-failure
ExecStart=/usr/bin/consul agent -config-dir="/etc/consul.d/"
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGINT

Environment=CONSUL_TOKEN=${hcp_acl_token}
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
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

mkdir -p /etc/systemd/resolved.conf.d
cat << EOSDRCF >/etc/systemd/resolved.conf.d/consul.conf
# Enable forward lookup of the 'consul' domain:
[Resolve]
Cache=no
DNS=127.0.0.1:8600
Domains=~.consul
EOSDRCF

cat << EOSDRLF >/etc/systemd/resolved.conf.d/listen.conf
# Enable listener on private ip:
[Resolve]
DNSStubListenerExtra=$${LOCAL_IPV4}
EOSDRLF

systemctl restart systemd-resolved.service

cat << EODDJ >/etc/docker/daemon.json
{
  "dns": ["$${LOCAL_IPV4}"],
  "dns-search": ["service.consul"]
}
EODDJ

systemctl restart docker.service
##################################

echo "==> Consul is done!"

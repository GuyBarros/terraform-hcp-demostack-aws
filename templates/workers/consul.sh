#!/usr/bin/env bash


echo "==> getting the aws metadata token"
export TOKEN=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

echo "==> check token was set"
echo $TOKEN


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
"advertise_addr": "$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4)",
"advertise_addr_wan": "$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/public-ipv4)",
"client_addr": "$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4) 127.0.0.1",
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

=$(ec2metadata --local-ipv4)

#####
# Configure resolving
#####

echo "Determining local IP address"
LOCAL_IPV4=$(ec2metadata --local-ipv4)


mkdir -p /etc/systemd/resolved.conf.d
cat << EOSDRCF >/etc/systemd/resolved.conf.d/consul.conf
# Enable forward lookup of the 'consul' domain:
[Resolve]
Cache=no
DNS=127.0.0.1:8600
DNSSEC=false
Domains=~.consul
EOSDRCF

cat << EOSDRLF >/etc/systemd/resolved.conf.d/listen.conf
# Enable listener on private ip:
[Resolve]
DNSStubListenerExtra=$(ec2metadata --local-ipv4)
EOSDRLF

systemctl restart systemd-resolved.service

cat << EODDJ >/etc/docker/daemon.json
{
  "dns": ["$(ec2metadata --local-ipv4)"],
  "dns-search": ["service.consul"]
}
EODDJ

systemctl restart docker.service

##################################

echo "==> Consul is done!"

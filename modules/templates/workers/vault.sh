#!/usr/bin/env bash
echo "==> Vault (server)"


echo "==> checking if we are using enterprise binaries"
echo "==> value of enterprise is ${enterprise}"

if [ ${enterprise} == 0 ]
then
echo "--> Fetching Vault OSS"
install_from_url "vault" "${vault_url}"

else
echo "--> Fetching Vault Ent"
install_from_url "vault" "${vault_ent_url}"
fi


echo "--> Attempting to create nomad role"

  echo "--> Adding Nomad policy"
  echo "--> Retrieving root token..."
  export VAULT_ADDR=${VAULT_ADDR}
  vault login token=${VAULT_TOKEN}
  export VAULT_NAMESPACE=admin

  vault policy write nomad-server - <<EOR
  path "auth/token/create/nomad-cluster" {
    capabilities = ["update"]
  }
  path "auth/token/revoke-accessor" {
    capabilities = ["update"]
  }
  path "auth/token/roles/nomad-cluster" {
    capabilities = ["read"]
  }
  path "auth/token/lookup-self" {
    capabilities = ["read"]
  }
  path "auth/token/lookup" {
    capabilities = ["update"]
  }
  path "auth/token/revoke-accessor" {
    capabilities = ["update"]
  }
  path "sys/capabilities-self" {
    capabilities = ["update"]
  }
  path "auth/token/renew-self" {
    capabilities = ["update"]
  }
  path "kv/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
}

path "pki/*" {
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

EOR

  vault policy write test - <<EOR
  path "kv/*" {
    capabilities = ["list"]
}

path "kv/test" {
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "kv/data/test" {
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "pki/*" {
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}


path "kv/metadata/cgtest" {
    capabilities = ["list"]
}


path "kv/data/cgtest" {
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
    control_group = {
        factor "approvers" {
            identity {
                group_names = ["approvers"]
                approvals = 1
            }
        }
    }
}

EOR


  echo "--> Creating Nomad token role"
  vault write auth/token/roles/nomad-cluster \
    name=nomad-cluster \
    period=259200 \
    renewable=true \
    orphan=false \
    disallowed_policies=nomad-server \
    explicit_max_ttl=0

 echo "--> Mount KV in Vault"
 {
 vault secrets enable -version=2 kv &&
  echo "--> KV Mounted succesfully"
 } ||
 {
   echo "--> KV Already mounted, moving on"
 }

 echo "--> Creating Initial secret for Nomad KV"
  vault kv put kv/test message='Hello world'


 echo "--> nomad nginx-vault-pki demo prep"
{
vault secrets enable pki
 }||
{
  echo "--> pki already enabled, moving on"
}

echo "--> pki generate internal ca "
 {
vault write pki/root/generate/internal common_name=service.consul
}||
{
  echo "--> pki generate internal already configured, moving on"
}
echo "--> pki generate role"
{
vault write pki/roles/consul-service generate_lease=true allowed_domains="service.consul" allow_subdomains="true"
}||
{
  echo "--> pki role already configured, moving on"
}
echo "--> configure superuser role"
{
vault policy write superuser - <<EOR
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }

  path "kv/*" {
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "kv/test/*" {
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "pki/*" {
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "sys/control-group/authorize" {
    capabilities = ["create", "update"]
}

# To check control group request status
path "sys/control-group/request" {
    capabilities = ["create", "update"]
}

# all access to boundary namespace
path "boundary/*" {
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}


EOR
} ||
{
  echo "--> superuser role already configured, moving on"
}

echo "--> Setting up Github auth"
 {
 vault auth enable github &&
 vault write auth/github/config organization=hashicorp &&
 vault write auth/github/map/teams/team-se  value=default,superuser
  echo "--> github auth done"
 } ||
 {
   echo "--> github auth mounted, moving on"
 }

 
 echo "-->Enabling transform"
 {
vault secrets enable  -path=/data-protection/masking/transform transform

echo "-->Configuring CCN role for transform"
vault write /data-protection/masking/transform/role/ccn transformations=ccn


echo "-->Configuring transformation template"
vault write /data-protection/masking/transform/transformation/ccn \
        type=masking \
        template="card-mask" \
        masking_character="#" \
        allowed_roles=ccn

echo "-->Configuring template masking"
vault write /data-protection/masking/transform/template/card-mask type=regex \
        pattern="(\d{4})-(\d{4})-(\d{4})-\d{4}" \
        alphabet="builtin/numeric"

echo "-->Test transform"
vault write /data-protection/masking/transform/encode/ccn value=2345-2211-3333-4356
 } ||
 {
   echo "-->Transform already configured"
 }
echo "-->Boundary setup"
{
vault namespace create boundary
 }||
{
  echo "--> Boundary namespace already created, moving on"
}

echo "-->mount transit in boundary namespace"
{
vault secrets enable  -namespace=admin/boundary -path=transit transit
 }||
{
  echo "--> transit already mounted, moving on"
}

echo "--> creating boundary root key"
{
vault  write -namespace=admin/boundary -f  transit/keys/root
 }||
{
  echo "--> root key already exists, moving on"
}

echo "--> creating boundary worker-auth key"
{
vault write -namespace=admin/boundary  -f  transit/keys/worker-auth
 }||
{
  echo "--> worker-auth key already exists, moving on"
}

echo "==> Vault is done!"
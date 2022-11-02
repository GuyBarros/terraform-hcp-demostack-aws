terraform state rm module.primarycluster.consul_acl_token.agent-token[0]
terraform state rm module.primarycluster.consul_acl_token.agent-token[1]
terraform state rm module.primarycluster.consul_acl_token.agent-token[2]
terraform state rm module.primarycluster.consul_acl_token_policy_attachment.anon-readonly-policy-attachment
terraform state rm module.primarycluster.consul_acl_policy.agent
terraform state rm module.primarycluster.consul_acl_policy.anon
terraform state rm module.primarycluster.consul_node.vault
make destroy
# terraform-hcp-demostack-aws
this is a nocode example repository that sets up resources on HCP (Vault, Consul, Boundary) and AWS(EC2 - hosting nomad, DBs) and interconnects the two.

## Solution Diagram
![Solution Diagram](./assets/HCP_Demostack_Module.png)



## using the module
besides added the mandatory TF variables when configuring the workspace, you will also need to add AWS and HCP creds via enviroment variables

### Doormat:
doormat aws --account <account_name> tf-push --organization <organization_name>  --workspace <workspace_name>  

### AWS:
* AWS_DEFAULT_REGION 

### HCP:
* HCP_CLIENT_ID
* HCP_CLIENT_SECRET (sensitive)







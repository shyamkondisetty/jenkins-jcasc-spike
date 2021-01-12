#!/bin/bash

# Setup the environment variables -
# make sure to set ConnectionStrings__PaymentConnection  and VAULT_ADDRvariable with appropriate value.

# Install vault
#brew install vault

export VAULT_ADDR=http://localhost:8081
# Initiate vault to have 1 unseal key (usually it should more than 3)
data=$(vault operator init -key-threshold=1 -key-shares=1)

unsealkey="$(echo "$data" | grep "Unseal Key 1: " | cut -c15-)"
roottoken="$(echo "$data" | grep "Root Token: " | cut -c21-)"

echo "Unseal Key : $unsealkey"
echo "Root Token : $roottoken"
# Unseal the Vault using Unseal Key
vault operator unseal $unsealkey

# Login to the Vault using Root Token
vault login $roottoken

# Enable Key Vault engine with jenkins as path.
vault secrets enable -version=2 -path=secret kv

vault kv put secret/jenkinscredentials qa_config=@devops-catalyst-qa.conf stage_config=@devops-catalyst-staging.conf systems_config=@devops-catalyst-democentral.conf githubtoken=bb4b01083686fa943991d40db7f90aafee3e4b6d nexuspassword=Thought@catalyst
#vault kv put secret/jenkins/credentials systems_config=@devops-catalyst-systems.conf
#vault kv put secret/jenkins/credentials stage_config=@devops-catalyst-staging.conf
#vault kv put secret/jenkins/credentials qa_config=@devops-catalyst-qa.conf

# Get the paths under jenkins kv engine.
vault kv list secret

# Get the secrets under jenkins/settings/.
vault kv get secret/jenkinscredentials

# Enable AppRole auth.
vault auth enable approle

# Format the policy located at policies.hcl under vault/policies folder.
#vault policy fmt policies/policies.hcl

# Create the policy.
vault policy write jenkins - <<EOF
path "secret/" {
  capabilities = ["read", "list"]
}

path "secret/*" {
  capabilities = ["read", "list"]
}
EOF

# Read the policy which just got created.
vault policy read jenkins

# Create a role and associate it with the policy created.
vault write auth/approle/role/jenkins secret_id_ttl=525600m secret_id_num_uses=0 policies=default,jenkins

# Read the Role id.
vault read auth/approle/role/jenkins/role-id

# Read the Secret Id associated with the role.
vault write -f auth/approle/role/jenkins/secret-id
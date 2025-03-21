#!/bin/bash

# Set your Terraform Cloud details
TFC_ORG="emea-se-playground-2019"  # Replace with your Terraform Cloud organization name
VARSET_NAME="com_showcase"

# Retrieve Terraform Cloud API token from credentials file
CREDENTIALS_FILE="$HOME/.terraform.d/credentials.tfrc.json"
TFC_API_TOKEN=$(jq -r '.credentials."app.terraform.io".token' "$CREDENTIALS_FILE")

# Check if API token was found
if [[ -z "$TFC_API_TOKEN" || "$TFC_API_TOKEN" == "null" ]]; then
    echo "Error: Terraform Cloud API token not found in $CREDENTIALS_FILE."
    exit 1
fi

# Terraform Cloud API URL
TFC_API_URL="https://app.terraform.io/api/v2"



# Get the variable set ID for "com_showcase"
VARSET_ID=$(curl -s \
  --header "Authorization: Bearer $TFC_API_TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --request GET \
  $TFC_API_URL/organizations/$TFC_ORG/varsets | \
            jq -r ".data[] | select(.attributes.name == \"$VARSET_NAME\") | .id")

# Check if variable set ID was found
if [[ -z "$VARSET_ID" ]]; then
    echo "Error: Variable set '$VARSET_NAME' not found."
    exit 1
fi

# Get the variable "boundary_address" from the variable set
BOUNDARY_ADDRESS=$(curl -s --header "Authorization: Bearer $TFC_API_TOKEN" \
                      --header "Content-Type: application/json" \
                      "$TFC_API_URL/varsets/$VARSET_ID/relationships/vars" | \
                  jq -r ".data[] | select(.attributes.key == \"boundary_address\") | .attributes.value")

# Check if the variable was found
if [[ -z "$BOUNDARY_ADDRESS" || "$BOUNDARY_ADDRESS" == "null" ]]; then
    echo "Error: 'boundary_address' variable not found in variable set '$VARSET_NAME'."
    exit 1
fi

# Output the boundary address
echo "boundary_address: $BOUNDARY_ADDRESS"
export BOUNDARY_ADDR=$BOUNDARY_ADDRESS
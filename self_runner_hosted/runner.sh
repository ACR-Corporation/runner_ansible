#!/bin/bash

RESOURCE_GROUP_NAME=rg_runner_aci
LOCATION=westeurope
ACR_NAME=peteracr007
RESOURCE_GROUP_ACR_NAME=rg_demo_container

IMAGE_NAME=peteracr007.azurecr.io/ansible
IMAGE_VERSION=0.0.4

REPO_NAME=ACR-Corporation/runner_ansible
TOKEN_GH=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

VNET_RUNNER=runner-vnet
SUBNET_RUNNER=runner-subnet

VNET_PREFIX=192.168.0.0/16
SUBNET_PREFIX=192.168.1.0/24


# Create a resource group.
echo "Creating resource group"
az group create \
   --name $RESOURCE_GROUP_NAME \
   --location $LOCATION

# Get password Azure Container Registry
echo "Getting the password for the container registry"
PWD_ACR=$(az acr credential show --name $ACR_NAME --resource-group $RESOURCE_GROUP_ACR_NAME --query "passwords[0].value" --output tsv)
echo $PWD_ACR

# Create the container instance in Azure Runner
echo "Creating runner"
az container create \
    --resource-group $RESOURCE_GROUP_NAME \
    --name runner-00 \
    --registry-username $ACR_NAME \
    --registry-password $PWD_ACR \
    --image $IMAGE_NAME:$IMAGE_VERSION \
    --restart-policy Always \
    --protocol TCP \
    --ports 443 \
    --environment-variables REPO=$REPO_NAME TOKEN=$TOKEN_GH \
    --ip-address Private \
    --vnet $VNET_RUNNER \
    --vnet-address-prefix $VNET_PREFIX \
    --subnet $SUBNET_RUNNER \
   --subnet-address-prefix $SUBNET_PREFIX




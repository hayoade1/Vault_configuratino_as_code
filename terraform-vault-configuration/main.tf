terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "2.15.0"
    }
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.36.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  features {}
}

provider "vault" {
  # Configuration options
}

resource "vault_auth_backend" "example" {
  type = "userpass"
}

resource "vault_policy" "admin_policy" {
  name   = "admins"
  policy = file("policies/admin_policy.hcl")
}

resource "vault_policy" "developer_policy" {
  name   = "developers"
  policy = file("policies/developer_policy.hcl")
}

resource "vault_policy" "operations_policy" {
  name   = "operations"
  policy = file("policies/operation_policy.hcl")
}


resource "vault_mount" "developers" {
  path        = "developers"
  type        = "kv-v2"
  description = "KV2 Secrets Engine for Developers"
}

resource "vault_mount" "operations" {
  path        = "operations"
  type        = "kv-v2"
  description = "KV2 Secrets Engine for Operations."
}

locals {
  se-region = "AMER - Canada"
  owner     = "sam.gabrail"
  purpose   = "demo for end-to-end infrastructure and application deployments"
  ttl       = "720"
  terraform = "true"
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    se-region = local.se-region
    owner     = local.owner
    purpose   = local.purpose
    ttl       = local.ttl
    terraform = local.terraform
  }
}

# Azure Secrets Engine Configuration
resource "azurerm_resource_group" "myresourcegroup" {
  name     = "${var.prefix}-jenkins"
  location = var.location

  tags = local.common_tags
}

resource "vault_azure_secret_backend" "azure" {
  subscription_id = var.subscription_id
  tenant_id = var.tenant_id
  client_secret = var.client_secret
  client_id = var.client_id
}

resource "vault_azure_secret_backend_role" "jenkins" {
  backend                     = vault_azure_secret_backend.azure.path
  role                        = "jenkins"
  ttl                         = "24h"
  max_ttl                     = "48h"

  azure_roles {
    role_name = "Contributor"
    scope =  "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.myresourcegroup.name}"
  }
}
//

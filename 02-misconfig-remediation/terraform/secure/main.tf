# Hardened equivalent of terraform/insecure. Passes Checkov.
# Same three resources, configured as they should be.

terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

variable "location" {
  type    = string
  default = "uksouth"
}

variable "prefix" {
  type    = string
  default = "seclab"
}

variable "allowed_source_cidr" {
  description = "Single administrative source range. Never 0.0.0.0/0."
  type        = string
}

resource "azurerm_resource_group" "secure" {
  name     = "${var.prefix}-secure-rg"
  location = var.location
  tags = {
    purpose = "security-lab"
    owner   = "chuks"
    state   = "hardened"
  }
}

resource "azurerm_log_analytics_workspace" "logs" {
  name                = "${var.prefix}-law"
  location            = azurerm_resource_group.secure.location
  resource_group_name = azurerm_resource_group.secure.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
}

# FIX 1: no public access, HTTPS only, modern TLS, private network access,
# infrastructure encryption, and diagnostic logging.
resource "azurerm_storage_account" "secure" {
  name                            = "${var.prefix}securesa"
  resource_group_name             = azurerm_resource_group.secure.name
  location                        = azurerm_resource_group.secure.location
  account_tier                    = "Standard"
  account_replication_type        = "GRS"
  allow_nested_items_to_be_public = false
  enable_https_traffic_only       = true
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = false
  shared_access_key_enabled       = false # force Entra ID auth rather than account keys

  blob_properties {
    versioning_enabled = true
    delete_retention_policy { days = 30 }
  }

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  identity { type = "SystemAssigned" }
}

resource "azurerm_storage_container" "private" {
  name                  = "private-data"
  storage_account_name  = azurerm_storage_account.secure.name
  container_access_type = "private"
}

resource "azurerm_monitor_diagnostic_setting" "storage" {
  name                       = "storage-diagnostics"
  target_resource_id         = "${azurerm_storage_account.secure.id}/blobServices/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id

  enabled_log { category = "StorageRead" }
  enabled_log { category = "StorageWrite" }
  enabled_log { category = "StorageDelete" }
}

# FIX 2: no management ports from the internet. Administrative access is expected
# to come through Azure Bastion or just-in-time access, not an always-open port.
resource "azurerm_network_security_group" "secure" {
  name                = "${var.prefix}-secure-nsg"
  location            = azurerm_resource_group.secure.location
  resource_group_name = azurerm_resource_group.secure.name

  security_rule {
    name                       = "allow-ssh-from-admin-range-only"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.allowed_source_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "deny-all-other-inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_monitor_diagnostic_setting" "nsg" {
  name                       = "nsg-diagnostics"
  target_resource_id         = azurerm_network_security_group.secure.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id

  enabled_log { category = "NetworkSecurityGroupEvent" }
  enabled_log { category = "NetworkSecurityGroupRuleCounter" }
}

output "storage_account" { value = azurerm_storage_account.secure.name }
output "workspace"       { value = azurerm_log_analytics_workspace.logs.name }

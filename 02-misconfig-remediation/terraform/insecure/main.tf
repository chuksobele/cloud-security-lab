# DELIBERATELY INSECURE - lab use only, in an isolated subscription.
# Excluded from Checkov in .checkov.yaml with documented rationale.
# Run `terraform destroy` immediately after capturing evidence.

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
  features {}
}

variable "location" {
  type    = string
  default = "uksouth"
}

variable "prefix" {
  type    = string
  default = "seclab"
}

resource "azurerm_resource_group" "insecure" {
  name     = "${var.prefix}-insecure-rg"
  location = var.location
  tags = {
    purpose = "security-lab"
    state   = "intentionally-insecure"
  }
}

# MISCONFIGURATION 1: public blob access, HTTP allowed, old TLS
resource "azurerm_storage_account" "insecure" {
  name                            = "${var.prefix}insecuresa"
  resource_group_name             = azurerm_resource_group.insecure.name
  location                        = azurerm_resource_group.insecure.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = true  # public blob access
  enable_https_traffic_only       = false # HTTP permitted
  min_tls_version                 = "TLS1_0"
  public_network_access_enabled   = true
}

resource "azurerm_storage_container" "public" {
  name                  = "public-data"
  storage_account_name  = azurerm_storage_account.insecure.name
  container_access_type = "blob" # anonymous read
}

# MISCONFIGURATION 2: management ports open to the internet
resource "azurerm_network_security_group" "insecure" {
  name                = "${var.prefix}-insecure-nsg"
  location            = azurerm_resource_group.insecure.location
  resource_group_name = azurerm_resource_group.insecure.name

  security_rule {
    name                       = "allow-ssh-from-anywhere"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-rdp-from-anywhere"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# MISCONFIGURATION 3 is applied manually in the portal:
# assign Owner at subscription scope to a test service principal, then remove it.
# Done by hand rather than in code so the assignment is short-lived and obvious.

output "storage_account" { value = azurerm_storage_account.insecure.name }
output "nsg"             { value = azurerm_network_security_group.insecure.name }

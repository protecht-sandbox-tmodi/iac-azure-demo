terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# INTENTIONAL GAP: this storage account opens itself to the public network
# AND drops below TLS 1.2.  The IaC scanner should fail it across SOC 2 CC6.6,
# CC6.1, ISO A.8.20, FedRAMP SC-7 + SC-8.
resource "azurerm_storage_account" "public_oops" {
  name                          = "protechttestpublic"
  resource_group_name           = "rg-protecht-iac-demo"
  location                      = "eastus"
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  https_traffic_only_enabled    = false
  public_network_access_enabled = false
  min_tls_version               = "TLS1_0"
}

# CORRECT: locked-down storage, should pass every storage rule.
resource "azurerm_storage_account" "private_good" {
  name                          = "protechttestprivate"
  resource_group_name           = "rg-protecht-iac-demo"
  location                      = "eastus"
  account_tier                  = "Standard"
  account_replication_type      = "GRS"
  https_traffic_only_enabled    = true
  public_network_access_enabled = false
  min_tls_version               = "TLS1_2"
}

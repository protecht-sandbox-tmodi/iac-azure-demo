terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# INTENTIONAL GAP: public network exposure + no purge protection.  Should
# fail keyvault_public_network_disabled (SOC 2 CC6.6, FedRAMP SC-7) and
# keyvault_purge_protection (SOC 2 CC6.7, ISO A.8.13, FedRAMP CP-9).
resource "azurerm_key_vault" "exposed" {
  name                          = "kv-iac-demo-bad"
  location                      = "eastus"
  resource_group_name           = "rg-protecht-iac-demo"
  tenant_id                     = "00000000-0000-0000-0000-000000000000"
  sku_name                      = "standard"
  public_network_access_enabled = true
  purge_protection_enabled      = false
}

# CORRECT: private endpoint + purge protection on.
resource "azurerm_key_vault" "locked_down" {
  name                          = "kv-iac-demo-good"
  location                      = "eastus"
  resource_group_name           = "rg-protecht-iac-demo"
  tenant_id                     = "00000000-0000-0000-0000-000000000000"
  sku_name                      = "premium"
  public_network_access_enabled = false
  purge_protection_enabled      = true
  soft_delete_retention_days    = 90
}

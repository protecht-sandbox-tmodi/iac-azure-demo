terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

resource "azurerm_network_security_group" "edge" {
  name                = "nsg-iac-demo"
  location            = "eastus"
  resource_group_name = "rg-protecht-iac-demo"
}

# INTENTIONAL GAP: SSH wide-open to the internet.  Should fail
# nsg_no_internet_ssh_rdp on SOC 2 CC6.6, ISO A.8.20, FedRAMP SC-7.
resource "azurerm_network_security_rule" "ssh_open" {
  name                        = "allow-ssh-everyone"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "rg-protecht-iac-demo"
  network_security_group_name = azurerm_network_security_group.edge.name
}

# Same problem, RDP this time (3389 inside a 3380-3400 range).
resource "azurerm_network_security_rule" "rdp_range" {
  name                        = "allow-rdp-range"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3380-3400"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = "rg-protecht-iac-demo"
  network_security_group_name = azurerm_network_security_group.edge.name
}

# CORRECT: SSH only from the office VPN range.
resource "azurerm_network_security_rule" "ssh_office" {
  name                        = "allow-ssh-office"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "10.0.0.0/8"
  destination_address_prefix  = "*"
  resource_group_name         = "rg-protecht-iac-demo"
  network_security_group_name = azurerm_network_security_group.edge.name
}

# CORRECT: deny all from internet by default.
resource "azurerm_network_security_rule" "deny_inbound_default" {
  name                        = "deny-all-inbound"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "rg-protecht-iac-demo"
  network_security_group_name = azurerm_network_security_group.edge.name
}

resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

#Resource Groups
resource "azurerm_resource_group" "rg1" {
  name     = random_pet.rg_name.id
  location = var.resource_group_location
}

#Create KeyVault ID
resource "random_id" "kvname" {
  byte_length = 5
  prefix      = "keyvault"
}

#Keyvault Creation
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv1" {
  depends_on                  = [azurerm_resource_group.rg1]
  name                        = random_id.kvname.hex
  location                    = var.resource_group_location
  resource_group_name         = random_pet.rg_name.id
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

/*   access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore", "Set",
    ]

    storage_permissions = [
      "Get",
    ]
  } */
}

resource "azurerm_key_vault_access_policy" "for_logged_in_user" {
  key_vault_id = azurerm_key_vault.kv1.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get", "Backup", "Delete", "List", "Purge", "Recover", "Restore", "Set",
    ]

    storage_permissions = [
      "Get",
    ]
}

#Create KeyVault VM password
resource "random_password" "vmpassword" {
  length  = 20
  special = true
}

#Create Key Vault Secret
resource "azurerm_key_vault_secret" "vmpassword" {
  name         = "vmpassword"
  value        = random_password.vmpassword.result
  key_vault_id = azurerm_key_vault.kv1.id
  depends_on   = [azurerm_key_vault.kv1]
}
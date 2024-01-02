resource "azurerm_resource_group" "rg" {
  name     = "${var.project_name}-${var.env_name}-rg"
  location = var.location
}

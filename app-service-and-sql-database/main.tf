resource "azurerm_resource_group" "RG-sdp-tf" {
  name     = "sdp-tf-resource-group"
  location = "North Europe"
}

resource "azurerm_service_plan" "SP-sdp-tf" {
  name                = "sdp-tf-appserviceplan"
  location            = azurerm_resource_group.RG-sdp-tf.location
  resource_group_name = azurerm_resource_group.RG-sdp-tf.name
  os_type             = "Windows"
  sku_name            = "F1"
}

resource "azurerm_windows_web_app" "AS-sdp-tf" {
  name                = "app-service-sdp-tf"
  location            = azurerm_resource_group.RG-sdp-tf.location
  resource_group_name = azurerm_resource_group.RG-sdp-tf.name
  service_plan_id     = azurerm_service_plan.SP-sdp-tf.id

  site_config {
    application_stack {
      dotnet_version = "v8.0"
    }
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=tcp:${azurerm_mssql_server.sdp-tf-sqlserver.fully_qualified_domain_name};Database=${azurerm_mssql_database.sdp-tf-sqldatabase.name};User ID=${azurerm_mssql_server.sdp-tf-sqlserver.administrator_login};Password=${azurerm_mssql_server.sdp-tf-sqlserver.administrator_login_password};Trusted_Connection=False;Encrypt=True;"
  }
}

resource "azurerm_mssql_server" "sdp-tf-sqlserver" {
  name                         = "sdp-tf-sqlserver"
  resource_group_name          = azurerm_resource_group.RG-sdp-tf.name
  location                     = azurerm_resource_group.RG-sdp-tf.location
  version                      = "12.0"
  administrator_login          = "sqladminuser"
  administrator_login_password = "P@ssw0rd-Str0ng!"
}

resource "azurerm_mssql_database" "sdp-tf-sqldatabase" {
  name      = "sdp-tf-sqldatabase"
  server_id = azurerm_mssql_server.sdp-tf-sqlserver.id

  tags = {
    environment = "production"
  }
}
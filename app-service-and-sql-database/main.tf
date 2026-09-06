resource "azurerm_resource_group" "RG-sdp-tf-webapp" {
  name     = "sdp-tf-webapp-resource-group"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "ASP-sdp-tf-webapp" {
  name                = "sdp-tf-webapp-appserviceplan"
  location            = azurerm_resource_group.RG-sdp-tf-webapp.location
  resource_group_name = azurerm_resource_group.RG-sdp-tf-webapp.name

  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "azurerm_app_service" "AS-sdp-tf-webapp" {
  name                = "app-service-sdp-tf-webapp"
  location            = azurerm_resource_group.RG-sdp-tf-webapp.location
  resource_group_name = azurerm_resource_group.RG-sdp-tf-webapp.name
  app_service_plan_id = azurerm_app_service_plan.ASP-sdp-tf-webapp.id

  site_config {
    dotnet_framework_version = "v8.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=tcp:${azurerm_sql_server.sdp-tf-webapp-sqlserver.fully_qualified_domain_name} Database=${azurerm_sql_database.sdp-tf-webapp-sqldatabase.name};User ID=${azurerm_sql_server.sdp-tf-webapp-sqlserver.administrator_login};Password=${azurerm_sql_server.sdp-tf-webapp-sqlserver.administrator_login_password};Trusted_Connection=False;Encrypt=True;"
  }
}

resource "azurerm_sql_server" "sdp-tf-webapp-sqlserver" {
  name                         = "sdp-tf-webapp-sqlserver"
  resource_group_name          = azurerm_resource_group.RG-sdp-tf-webapp.name
  location                     = azurerm_resource_group.RG-sdp-tf-webapp.location
  version                      = "12.0"
  administrator_login          = "admin"
  administrator_login_password = "Subbu@2020"
}

resource "azurerm_sql_database" "sdp-tf-webapp-sqldatabase" {
  name                = "sdp-tf-webapp-sqldatabase"
  resource_group_name = azurerm_resource_group.RG-sdp-tf-webapp.name
  location            = azurerm_resource_group.RG-sdp-tf-webapp.location
  server_name         = azurerm_sql_server.sdp-tf-webapp-sqlserver.name

  tags = {
    environment = "production"
  }
}
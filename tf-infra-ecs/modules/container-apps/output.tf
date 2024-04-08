output "ingress_url" {
    value = azurerm_container_app.main.latest_revision_fqdn
}

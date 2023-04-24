resource "azurerm_app_service_source_control" "this" {
  app_id   = var.web_app_id
  repo_url = var.repo_url
  branch   = "main"

  github_action_configuration {
    code_configuration {
      runtime_stack = "python"
      runtime_version = "3.10"
    }
  }
}
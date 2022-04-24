locals {
  # A map of tags to assign to the services. It's sort of required to define 
  # in order to get billing for specific BU, Project and Environment,
  common_tags = {
    "BusinessUnit" = var.business_unit,
    "Environment"  = var.environment,
    "Project"      = var.project,
    "ManagedBy"    = "Terraform"
  }
}

# ----------------------------------------------------------------------------
# Root Terragrunt configuration
# ----------------------------------------------------------------------------
# Every leaf `terragrunt.hcl` does:
#
#   include "root" {
#     path = find_in_parent_folders("root.hcl")
#   }
#
# This file gives every component:
#   * Auto-generated provider block (per cloud, chosen by env.hcl)
#   * Remote state backend (per cloud)
#   * Common inputs (env, cloud, region, owner, tags)
# ----------------------------------------------------------------------------

# Discover cloud + env from the directory layout: live/<cloud>/<env>/<component>
locals {
  # env.hcl lives at live/<cloud>/<env>/env.hcl and defines cloud, env, region, etc.
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  cloud  = local.env_vars.locals.cloud  # "azure" | "aws" | "gcp"
  env    = local.env_vars.locals.env    # "dev" | "staging" | "prod"
  region = local.env_vars.locals.region
  name   = local.env_vars.locals.name
  owner  = lookup(local.env_vars.locals, "owner", "platform-team")

  common_tags = {
    environment = local.env
    cloud       = local.cloud
    owner       = local.owner
    managed_by  = "terragrunt"
    platform    = "idp"
  }
}

# ----------------------------------------------------------------------------
# Remote state — one backend per cloud
# ----------------------------------------------------------------------------
remote_state {
  backend = lookup(
    {
      azure = "azurerm"
      aws   = "s3"
      gcp   = "gcs"
    },
    local.cloud,
  )

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = lookup(
    {
      azure = {
        resource_group_name  = "GaytriRG"
        storage_account_name = "sttfidpq92b45"
        container_name       = "tfstate"
        key                  = "${local.cloud}/${local.env}/${path_relative_to_include()}/terraform.tfstate"
        use_azuread_auth     = true
      }
      aws = {
        bucket         = "tfstate-idp-${local.env}"
        key            = "${local.cloud}/${local.env}/${path_relative_to_include()}/terraform.tfstate"
        region         = local.region
        encrypt        = true
        dynamodb_table = "tfstate-locks"
      }
      gcp = {
        bucket = "tfstate-idp-${local.env}"
        prefix = "${local.cloud}/${local.env}/${path_relative_to_include()}"
      }
    },
    local.cloud,
  )
}

# ----------------------------------------------------------------------------
# Auto-generated provider — picks the right one for the cloud
# ----------------------------------------------------------------------------
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"

  # NOTE: only the provider *configuration* is generated here.
  # `required_providers` is declared inside each module's own versions.tf so
  # the modules remain usable standalone (terraform apply without terragrunt).
  contents = lookup(
    {
      azure = <<-EOF
        provider "azurerm" {
          features {
            resource_group {
              prevent_deletion_if_contains_resources = false
            }
          }
        }
      EOF

      aws = <<-EOF
        provider "aws" {
          region = "${local.region}"
          default_tags { tags = ${jsonencode(local.common_tags)} }
        }
      EOF

      gcp = <<-EOF
        provider "google" {
          region = "${local.region}"
        }
      EOF
    },
    local.cloud,
  )
}

# ----------------------------------------------------------------------------
# Inputs available to every component
# ----------------------------------------------------------------------------
inputs = {
  name     = local.name
  location = local.region
  tags     = local.common_tags
}

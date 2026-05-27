# ----------------------------------------------------------------------------
# EKS module (STUB — implement to match the aks/ interface)
# ----------------------------------------------------------------------------
# This module is a placeholder so the Terragrunt multi-cloud abstraction works
# end-to-end. Replace the body with real resources when AWS is in scope.
#
# Recommended implementation: wrap the community module
#   terraform-aws-modules/eks/aws (~> 20.0)
# and expose the variables declared in variables.tf.
# ----------------------------------------------------------------------------

locals {
  cluster_name = "eks-${var.name}"
  base_tags = merge(
    {
      "managed-by" = "terraform"
      "platform"   = "idp"
      "component"  = "eks"
    },
    var.tags,
  )
}

# TODO: VPC (aws_vpc + subnets in availability_zones)
# TODO: EKS cluster via terraform-aws-modules/eks/aws
# TODO: Managed node groups (system + apps) using var.system_node_vm_size / var.user_node_vm_size
# TODO: IRSA, aws-load-balancer-controller IAM, OIDC provider

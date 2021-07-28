resource "aws_route53_record" "mfi-account-oracle-gateway-private" {
  count   = var.use_mfi_account_oracle_endpoint == "yes" ? 1 : 0
  zone_id = data.terraform_remote_state.infrastructure.outputs.private_zone_id
  name    = var.mfi_account_oracle_name
  type    = "A"
  ttl     = "300"
  records = [data.terraform_remote_state.infrastructure.outputs.haproxy_gateway_private_ip]
}

resource "helm_release" "mfi-account-oracle" {
  count      = var.use_mfi_account_oracle_endpoint == "yes" ? 1 : 0
  name       = "mfi-account-oracle"
  repository = "https://${var.private_helm_repo_read_key}@raw.githubusercontent.com/modusintegration/mfi-account-oracle/repo"
  chart      = "mfi-account-oracle"
  version    = var.helm_mfi_account_oracle_version
  namespace  = "mojaloop"
  timeout    = 300

  values = [
    templatefile("${path.module}/templates/values-mfi-account-oracle.yaml.tpl", {
      private_registry_pw = var.ghcr_private_registry_pw,
      private_registry_repo = var.ghcr_private_registry_reg
      private_registry_user = var.ghcr_private_registry_user
      ingress_host        = aws_route53_record.mfi-account-oracle-gateway-private[0].fqdn
    })
  ]
  provider = helm.helm-gateway
  depends_on = [helm_release.mojaloop]
}

output "mfi-account-oracle-fqdn" {
  description = "FQDN for the private hostname of the Internal GW service."
  value = var.use_mfi_account_oracle_endpoint == "yes" ? aws_route53_record.mfi-account-oracle-gateway-private[0].fqdn : "not used"
}

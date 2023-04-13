locals {
  secrets = {
    "secret-poc"  = "my-bastion-key.pem",
    "secret-poc2" = "bastion-key.pem"
  }
}

data "aws_secretsmanager_secret" "secrets" {
  for_each = local.secrets

  name = each.key
}

data "aws_secretsmanager_secret_version" "secrets" {
  for_each = data.aws_secretsmanager_secret.secrets

  secret_id = each.value.id
}

resource "null_resource" "secrets_files" {
  for_each = local.secrets
 

  triggers = {
    secret_version_id = data.aws_secretsmanager_secret_version.secrets[data.aws_secretsmanager_secret.secrets[each.key].name].version_id
  }

  provisioner "local-exec" {
    command = "echo '${data.aws_secretsmanager_secret_version.secrets[data.aws_secretsmanager_secret.secrets[each.key].name].secret_string}' > ${each.value}"
  }
}
resource "null_resource" "delete_secrets_files" {
  for_each = data.aws_secretsmanager_secret.secrets


  provisioner "local-exec" {
    command = "rm -f ${each.value.filename}"
  }
}

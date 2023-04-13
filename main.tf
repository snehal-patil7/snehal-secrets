locals {
  secrets = {
    "snehal_privatekey" = "my-bastion-key.pem",
    "snehal_cert"       = "cert.txt"
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

/*resource "null_resource" "delete_local_files" {
  provisioner "local-exec" {
    command = "rm my-bastion-key.pem && rm cert.txt"
  }
  depends_on = [terraform.apply]
}*/
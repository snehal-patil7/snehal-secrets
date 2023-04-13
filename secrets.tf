provider "aws" {
  region = "eu-north-1"
}

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

resource "local_file" "secrets_files" {
  for_each = local.secrets

  content = data.aws_secretsmanager_secret_version.secrets[each.key].secret_string

  filename = each.value
 
}

resource "null_resource" "secrets_files_test" {
  for_each = local.secrets

  triggers = {
    secret_version_id = data.aws_secretsmanager_secret_version.secrets[each.key].version_id
  }

  provisioner "local-exec" {
   command = "echo '${data.aws_secretsmanager_secret_version.secrets[data.aws_secretsmanager_secret.secrets[each.key].name].secret_string}' > ${local_file.secrets_files[each.key].filename}"
  }
}

resource "null_resource" "delete_secrets_files" {
  for_each = local_file.secrets_files

  triggers = {
    file_path = each.value.filename
  }

  provisioner "local-exec" {
    command = "rm -f ${each.value.filename}"
  }
}


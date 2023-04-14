resource "null_resource" "apply_terraform" {
  provisioner "local-exec" {
    command = "terraform apply"
  }
}

resource "null_resource" "delete_secret_files" {
  provisioner "local-exec" {
    command = "./delete_secret_files"
  }

  depends_on = [null_resource.apply_terraform]
}

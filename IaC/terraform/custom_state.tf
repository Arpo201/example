resource "terraform_data" "resource" {
  # trigger is not work for now, but comparison of hash version from 2 files are usable
  triggers_replace = aws_ssoadmin_permission_set.this
  lifecycle {
    replace_triggered_by = [ terraform_data.new_version.content_md5 ]
  }
}

resource "terraform_data" "always_run" {
  triggers_replace = aws_ssoadmin_permission_set.this
}

resource "terraform_data" "current_version" {
  triggers_replace = terraform_data.always_run
  provisioner "local-exec" {
    command = "echo 'v1.0.0' > $FILE_PATH"

    environment = {
      FILE_PATH = "${path.module}/current_version.txt"
    }
    interpreter = ["/bin/bash", "-c"]
  }

  lifecycle {

  }
}
data "local_file" "current_version" {
  filename   = "${path.module}/current_version.txt"
  depends_on = [terraform_data.current_version]
}


resource "terraform_data" "new_version" {
  triggers_replace = terraform_data.always_run
  provisioner "local-exec" {
    command = "echo 'v2.0.0' > $FILE_PATH"

    environment = {
      FILE_PATH = "${path.module}/new_version.txt"
    }
    interpreter = ["/bin/bash", "-c"]
  }
}
data "local_file" "new_version" {
  filename   = "${path.module}/new_version.txt"
  depends_on = [terraform_data.new_version]
}

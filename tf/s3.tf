resource "null_resource" "generate_zip" {
  provisioner "local-exec" {
    command = "cd .. && wsl bash ./generar-zip.sh"
    working_dir = "${path.module}"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

resource "aws_s3_bucket" "code_bucket" {
  bucket = "ai4devs-project-code-bucket-cnv"
  depends_on = [null_resource.generate_zip]
}

resource "aws_s3_bucket_ownership_controls" "code_bucket_ownership" {
  bucket = aws_s3_bucket.code_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "code_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.code_bucket_ownership]
  bucket = aws_s3_bucket.code_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "code_bucket_versioning" {
  bucket = aws_s3_bucket.code_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "code_bucket_encryption" {
  bucket = aws_s3_bucket.code_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_object" "backend_zip" {
  bucket = aws_s3_bucket.code_bucket.bucket
  key    = "backend.zip"
  source = "${path.module}/../backend.zip"
  depends_on = [
    aws_s3_bucket.code_bucket,
    aws_s3_bucket_acl.code_bucket_acl,
    aws_s3_bucket_versioning.code_bucket_versioning,
    aws_s3_bucket_server_side_encryption_configuration.code_bucket_encryption
  ]
}

resource "aws_s3_object" "frontend_zip" {
  bucket = aws_s3_bucket.code_bucket.bucket
  key    = "frontend.zip"
  source = "${path.module}/../frontend.zip"
  depends_on = [
    aws_s3_bucket.code_bucket,
    aws_s3_bucket_acl.code_bucket_acl,
    aws_s3_bucket_versioning.code_bucket_versioning,
    aws_s3_bucket_server_side_encryption_configuration.code_bucket_encryption
  ]
}

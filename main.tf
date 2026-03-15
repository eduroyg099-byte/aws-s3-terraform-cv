provider "aws" {
region = var.region
}

resource "aws_s3_bucket" "cvEdu"{
bucket=var.bucket_name
}

resource "aws_s3_bucket_website_configuration" "web_config"{
bucket=aws_s3_bucket.cvEdu.id
index_document{
    suffix="index.html"
 }
}
/*
resource "aws_cloudfront_origin_access_control" "default"{
name="oc-cvEdu"
origin_access_control_origin_type="s3"
signing_behavior="always"
signing_protocol="sigv4"
}
*/
 /*
resource "aws_cloudfront_distribution" "s3_distribution"{
origin{
    domain_name=aws_s3_bucket.cvEdu.bucket_regional_domain_name
    origin_id="S3Origin"
    origin_access_control_id=aws_cloudfront_origin_access_control.default.id
}
enabled=true
default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
*/
# Quitar el bloqueo de acceso público (AWS lo bloquea por defecto por seguridad)
resource "aws_s3_bucket_public_access_block" "public_block" {
  bucket = aws_s3_bucket.cvEdu.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 4. Crear una política para que CUALQUIERA pueda leer el contenido (necesario para una web)
resource "aws_s3_bucket_policy" "public_read_policy" {
  # Esperamos a que se quite el bloqueo de acceso público antes de aplicar la política
  depends_on = [aws_s3_bucket_public_access_block.public_block]
  
  bucket = aws_s3_bucket.cvEdu.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.cvEdu.arn}/*"
      },
    ]
  })
}
resource "aws_s3_object" "upload_cv"{
bucket=aws_s3_bucket.cvEdu.id
key="index.html"
source="index.html"
content_type="text/html"
}
output "url_web_s3" {
  value = aws_s3_bucket_website_configuration.web_config.website_endpoint
}
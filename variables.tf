variable "region" {
  description = "Región de AWS donde desplegaremos los recursos"
  type        = string
  default     = "eu-west-1" # Irlanda suele ser buena opción para España
}

variable "bucket_name" {
  description = "Nombre único global para el bucket de S3"
  type        = string
}


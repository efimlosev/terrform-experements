variable "namespace" {
  type    = string
  default = "efim"

}

variable "iam-policy-name" {
  type    = string
  default = "AWSLambdaS3Policy"

}

variable "iam-role-name" {
  type    = string
  default = "lambda-s3-role"

}

variable "event-name" {
  type    = string
  default = "lambda-trigger"

}
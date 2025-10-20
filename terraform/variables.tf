variable "region" {
  description = "Passing aws region to main.tf"
  type        = string
  default     = ""
}

variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

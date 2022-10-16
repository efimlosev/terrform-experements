variable "ssh_key" {
  default = "~/.ssh/module-3.pub"
  type    = string
}
variable "ssh_user" {
  type    = string
  default = "ec2-user"
}

variable "password" {

  type = string
  sensitive = false
}
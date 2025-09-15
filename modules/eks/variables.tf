variable "env" {
  type = string
}

variable "subnet_ids" {
  type        = list(string)
  description = "subnet ids"
}

variable "region" {
  type = string
  description = "provide the required region"
}

variable "cidr_block" {
  type = string
  description = "provide your cidr range"
}

variable "availability_zone1" {
  default = string

}

variable "availability_zone2" {
  type = string
}

variable "subnet1_cidr" {
  type = string
}

variable "subnet2_cidr" {
  type = string
}


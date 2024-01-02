variable project_name {
  type        = string
  default     = ""
  description = "Name of the project"
}
variable env_name {
  type        = string
  default     = ""
  description = "Name of the Environment"
}
variable location {
  type        = string
  default     = "eastus"
  description = "Name of the region"
}
variable vnet_cidr {
  type        = string
  default     = "10.0.0.0/16"
  description = "Range of the vnet cidr"
}
variable subnet1_cidr {
  type        = string
  default     = "10.0.1.0/24"
  description = "Range of the subnet1 cidr"
}
variable subnet2_cidr {
  type        = string
  default     = "10.0.2.0/24"
  description = "Range of the subnet2 cidr"
}
variable vm_size {
  type        = string
  default     = ""
  description = "size of the virtual machine"
}






variable "name_machine" {
    type = string
    description = "Name machine that is used as prefix for the resources"
}

variable "location"{
    type = string
    default = "West Europe"
    description = "Location"
}

variable "resource_group_name"{
    type = string
    description = "Name of the resource group"
}

variable "subnet_id" {
    type = string
    description = "Subnet id"
}

variable "username"{
    type = string
    description = "Username ssh vm"
}
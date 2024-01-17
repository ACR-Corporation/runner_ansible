variable "resource_group_name" {
    description = "Name of the resource group"
    type        = string
}

variable "location" {
    description = "Location of the resource group"
    type        = string
}

variable "vnet_name" {
    description = "Name of the virtual network"
    type        = string
}

variable "vnet_address_space" {
    description = "Address space of the virtual network"
    type        = list(string)
}

variable "subnet_name" {
    description = "Name of the subnet"
    type        = string
}

variable "subnet_address_prefixes" {
    description = "Address prefixes of the subnet"
    type        = list(string)
}

variable "nsg_name" {
    description = "Name of the network security group"
    type        = string
}

variable "vm_name" {
    description = "Name of the virtual machine"
    type        = string  
}

variable "vm_size" {
    description = "Size of the virtual machine"
    type        = string
}

variable "vm_username" {
    description = "Username of the virtual machine"
    type        = string
}

variable "vm_username_password" {
    description = "Password of the virtual machine"
    type        = string  
}

variable "key_pub_ssh" {
    description = "key pub ssh"
    type        = string
}
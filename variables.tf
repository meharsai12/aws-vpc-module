variable "project" {

  
}

variable "environment" {


  
}


variable "vpc_tags" {
    default = {}
  
}

variable "igw_tags" {
    default = {}
  
}

variable "public_subnet_cidr" {
}

variable "public_subnet_tags" {
    default = {}
  
}



variable "private_subnet_cidr" {
}

variable "private_subnet_tags" {
    default = {}
  
}

variable "database_subnet_cidr" {
}

variable "database_subnet_tags" {
    default = {}
  
}


variable "eip_tags" {
    default = {}
  
}


variable "natgw_tags" {

    default = {}
  
}


variable "public_route_table_tags" {
    default = {}
  
}

variable "private_route_table_tags" {
    default = {}
  
}

variable "database_route_table_tags" {
    default = {}
  
}


variable "is_peering_required" {
    default = "false"
  
}


variable "peering_tags" {
    default = {}
  
}


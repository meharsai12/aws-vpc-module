data "aws_availability_zones" "available" {
  state = "available"
}



output "availability_zone" {
   value = data.aws_availability_zones.available.names
  
}


data "aws_vpc" "default" {
  default = true
}


data "aws_route_table" "main" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name = "association.main"
    values = ["true"]
  }
  
}


output "vpc_id" {

  value = aws_vpc.main.id
  
}


output "public_subnet_ids" {
  value = aws_subnet.public[*].id
  
}

output "private_subnet_ids" {
  value = aws_subnet.public[*].id
  
}


output "database_subnet_ids" {
  value = aws_subnet.public[*].id
  
}


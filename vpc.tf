# VPC CReation   roboshop-dev or prod 0r qa 
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = "true"

  tags = merge(
   var.vpc_tags, local.common_tags,
    {
        Name = "${var.project}-${var.environment}"
    }
  )
}


#Internet gateway creation and adding it to vpc    roboshop-dev or prod or qa
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.igw_tags,local.common_tags,
    {
        Name = "${var.project}-${var.environment}"
    }
  )
}


#public subnet creation   roboshop-dev or qa or prod -public-us - east - 1a or 1b 
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr[count.index]
  map_public_ip_on_launch = "true"
  availability_zone = slice(data.aws_availability_zones.available.names, 0 , 2)[count.index]


  tags = merge(
    var.public_subnet_tags,local.common_tags,
    {
        Name = "${var.project}-${var.environment}-public-${slice(data.aws_availability_zones.available.names, 0 , 2)[count.index]}"
    }
  )
    
  
}



#private subnet creation   roboshop-dev or qa or prod -private -us - east - 1a or 1b 
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr[count.index]
  availability_zone = slice(data.aws_availability_zones.available.names, 0 , 2)[count.index]


  tags = merge(
    var.private_subnet_tags,local.common_tags,
    {
        Name = "${var.project}-${var.environment}-private-${slice(data.aws_availability_zones.available.names, 0 , 2)[count.index]}"
    }
  )
    
  
}

#databse subnet creation  roboshop-dev or qa or prod -database -us - east - 1a or 1b 
resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidr[count.index]
  availability_zone = slice(data.aws_availability_zones.available.names, 0 , 2)[count.index]


  tags = merge(
    var.database_subnet_tags,local.common_tags,
    {
        Name = "${var.project}-${var.environment}-database-${slice(data.aws_availability_zones.available.names, 0 , 2)[count.index]}"
    }
  )
    
  
}

#Elastic ip creation    roboshop-dev 0r qa or prod -eip
resource "aws_eip" "eip" {
  domain   = "vpc"

  tags = merge(
    local.common_tags,var.eip_tags,
    {
        Name = "${var.project}-${var.environment}-eip"
    }
  )
}

#nat gate way is created and added to 1a public subnet     roboshop-dev -nat
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.natgw_tags , local.common_tags,
    {
        Name = "${var.project}-${var.environment}-nat"
    }
  )

  depends_on = [ aws_internet_gateway.igw ]
}



#public route table is created 
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
        var.public_route_table_tags, local.common_tags,
        {
            Name = "${var.project}-${var.environment}-public"
        }
    )
  }


#private route table is created 
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags =  merge(
        var.private_route_table_tags, local.common_tags,
        {
            Name = "${var.project}-${var.environment}-private"
        }
    )
  }



#database route table is created 
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
        var.database_route_table_tags, local.common_tags,
        {
            Name = "${var.project}-${var.environment}-database"
        }
    )
  }



# setting rules for public route  public igw is added and internet cidr

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}


# setting rules for public route  nat gate way  is added and internet cidr
resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_gw.id
}

# setting rules for public route  nat gate way  is added and internet cidr
resource "aws_route" "database" {
  route_table_id         = aws_route_table.database.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_gw.id
}


#public route table association
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


#private route table association
resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidr)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


#database route table association
resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidr)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}


#Create the VPC
resource "aws_vpc" "esr_vpc" {          #Creating VPC 
    cidr_block = var.esr_vpc_cidr        # Defining the CIDR Block use 10.0.0.0/16 for demo
    instance_tenancy = "default"
}

#Create Internet Gateway and attache it to VPC.
resource "aws_internet_gateway" "esrgw" {
    vpc_id = aws_vpc.esr_vpc.id
 
}
#Create a Public Subnets.
resource "aws_subnet" "esrpub_subnet" {
    vpc_id = aws_vpc.esr_vpc.id
    cidr_block = "${var.esr_public_subnets}"
}
#Create a Private Subnets.
resource "aws_subnet" "esrprv_subnet" {
    vpc_id = aws_vpc.esr_vpc.id
    cidr_block = "${var.esr_private_subnets}"

}
#Create Route table for Public Subnets
resource "aws_route_table" "esr_pubrt" {
    vpc_id = aws_vpc.esr_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.esrgw.id
       
        }
    }
#Create Route table for private SUbnets.
resource "aws_route_table" "esr_prvrt" {
    vpc_id = aws_vpc.esr_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.esr_natgw
        }
    }
#Route table Association with Public Subnets
resource "aws_route_table_association" "esr_pub_rta" {
    subnet_id = aws_subnet.esrpub_subnet.id
    route_table_id = aws_route_table.esr_pubrt.id 
}
#Route table Association with Private Subnets
resource "aws_route_table_association" "esr_prv_rta" {
    subnet_id = aws_subnet.esrprv_subnet.id
    route_table_id = aws_route_table.esr_prvrt.id
}

#Create EIP
resource "aws_eip" "natip" {
    vpc = true
}

#Create Nat Gateway
resource "aws_nat_gateway" "esr_natgw" {
    allocation_id = aws_eip.natip.id
    subnet_id = aws_subnet.esrpub_subnet.id
}
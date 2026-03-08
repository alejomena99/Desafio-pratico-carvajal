output "az" {
  value = data.aws_availability_zones.available.names
}

output "numero_az" {
  value = length(data.aws_availability_zones.available.names)
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.gw.id
}

output "public_route_table_id" {
  value = aws_route_table.public_rt.id
}

output "private_route_table_id" {
  value = aws_route_table.private_rt.id
}
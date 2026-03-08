# Elastic IP
resource "aws_eip" "nat_eip" {
  tags = merge(var.tags, {
    Name = format(
      "%s-nat-eip-%s",
      var.tags["Environment"],
      var.nat_index
    )
  })
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(var.public_subnet_ids, var.nat_index - 1)

  tags = merge(var.tags, {
    Name = format(
      "%s-nat-gw-%s",
      var.tags["Environment"],
      var.nat_index
    )
  })
}

# Route
resource "aws_route" "private_nat_route" {
  route_table_id         = var.private_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}
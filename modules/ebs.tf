

resource "aws_ebs_volume" "mysql" {
  availability_zone       = data.aws_availability_zones.available.names[0]
  size              = 40
}

resource "aws_ebs_volume" "mongodb" {
  availability_zone       = data.aws_availability_zones.available.names[0]
  size              = 40
}

resource "aws_ebs_volume" "prometheus" {
  availability_zone       = data.aws_availability_zones.available.names[0]
  size              = 40
}

resource "aws_ebs_volume" "shared" {
  availability_zone       = data.aws_availability_zones.available.names[0]
  size              = 40
}

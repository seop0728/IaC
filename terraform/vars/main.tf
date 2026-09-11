locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.project_environment
  }

  suffix_name = "${var.project_name}-${var.project_environment}"
}

resource "aws_instance" "instance_a" {
  ami           = var.ami_image[var.aws_region]
  instance_type = var.instance_type

  tags = {
    Name = "instance-a-${local.suffix_name}"
  }
}

resource "aws_instance" "instance_b" {
  ami           = var.ami_image[var.aws_region]
  instance_type = var.instance_type

  tags = {
    Name = "instance-b-${local.suffix_name}"
  }
}

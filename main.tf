 
provider "aws" {
  region = "eu-west-2"
  access_key = "ACCESS_KEY"
  secret_key = "SECRET_KEY"
}

resource "aws_instance" "example" {
  ami = "ami-0be057a22c63962cb"
  instance_type = "t2.micro"
}

resource "aws_db_instance" "db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "11.5"
  instance_class       = "db.t2.micro"
  name                 = "wikipedia"
  username             = "postgres"
  password             = "password"
  parameter_group_name = "default.postgres11"
  skip_final_snapshot  = true #
  deletion_protection  = false#
  publicly_accessible  = true #
  # storage_encrypted    = true
}

output "rds_endpoint" {
  value = "${aws_db_instance.db.endpoint}"
}

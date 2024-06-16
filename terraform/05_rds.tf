# ------------------------------------------------------------#
#  rds subnet groupe
# ------------------------------------------------------------#
resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "${var.tag_name}-db-subnet-group"
  description = "for ${var.tag_name}_db_subnet_group"
  subnet_ids  = [aws_subnet.private_sub_a.id, aws_subnet.private_sub_c.id]
  tags = {
    Name = "${var.tag_name}-db-subnet-group"
  }
}

# ------------------------------------------------------------#
#  rds
# ------------------------------------------------------------#
resource "aws_db_instance" "rds" {
  identifier                  = "${var.tag_name}-rds"
  engine                      = "mysql"
  engine_version              = "8.0.35"
  multi_az                    = true
  username                    = "foo"
  manage_master_user_password = true
  instance_class              = "db.t3.micro"
  storage_type                = "gp2"
  allocated_storage           = 20
  db_subnet_group_name        = aws_db_subnet_group.db_subnet_group.name
  publicly_accessible         = false
  vpc_security_group_ids      = [aws_security_group.rds_sg.id]
  #availability_zone           = "${var.region}a"
  port                       = 3306
  parameter_group_name       = aws_db_parameter_group.db_parameter_group.name
  option_group_name          = aws_db_option_group.db_option_group.name
  backup_retention_period    = 0
  skip_final_snapshot        = true
  auto_minor_version_upgrade = false
  tags = {
    Name = "${var.tag_name}-rds"
  }
}

resource "aws_db_parameter_group" "db_parameter_group" {
  name   = "${var.tag_name}-db-parameter-group"
  family = "mysql8.0"
  tags = {
    Name = "${var.tag_name}-db-parameter-group"
  }
}

resource "aws_db_option_group" "db_option_group" {
  name                 = "${var.tag_name}-db-option-group"
  engine_name          = "mysql"
  major_engine_version = "8.0"
  tags = {
    Name = "${var.tag_name}-db-option-group"
  }
}


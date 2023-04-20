resource "aws_security_group" "rds_sg" {
  name        = var.rds_sg_name
  description = "RDS security group."
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = var.rds_port
    to_port         = var.rds_port
    security_groups = [var.ecs_sg_id]
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "rds_subnet_group"
  description = "Subnet group for RDS"
  subnet_ids  = [var.private_subnet_3_id, var.private_subnet_4_id]

  tags = {
    Name = "RDS subnet group"
  }
}

resource "aws_db_parameter_group" "flask_demo_db" {
  name   = "flask-demo-db"
  family = "postgres14"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_db_instance" "flask_demo_db" {
  identifier              = "flask-demo-db"
  instance_class          = "db.t3.micro"
  allocated_storage       = 5
  engine                  = "postgres"
  engine_version          = "14.1"
  username                = "postgres"
  password                = "postgres"
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  parameter_group_name    = aws_db_parameter_group.flask_demo_db.name
  publicly_accessible     = false
  skip_final_snapshot     = true
  availability_zone       = "us-east-1a"
  backup_retention_period = 7
}

#resource "aws_db_instance" "flask_demo_db_replica" {
#  identifier             = "flask-demo-db-replica"
#  instance_class         = "db.t3.micro"
#  allocated_storage      = 5
#  engine                 = "postgres"
#  engine_version         = "14.1"
#  vpc_security_group_ids = [aws_security_group.rds_sg.id]
#  parameter_group_name   = aws_db_parameter_group.flask_demo_db.name
#  publicly_accessible    = false
#  skip_final_snapshot    = true
#  availability_zone      = "us-east-1e"
#
#  # Specify the primary RDS instance as the source
#  replicate_source_db = aws_db_instance.flask_demo_db.id
#}

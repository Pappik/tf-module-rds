resource "aws_db_subnet_group" "default" {
  name       = "${var.env}-rds_subnet_group"
  subnet_ids = var.subnet_ids

  tags = merge(local.common_tags, { Name = "${var.env}-rds_subnet_group"} )

}

resource "aws_security_group" "rds" {
  name        = "${var.env}-rds_security_group"
  description = "${var.env}-rds_security_group"
  vpc_id      = var.vpc_id

  ingress {
    description = "Rds"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.allow_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.env}-rds_security_group"} )
}

resource "aws_rds_cluster" "rds" {
  cluster_identifier      = "${var.env}-rds"
  engine                  = var.engine
  engine_version          = var.engine_version
  db_cluster_instance_class = var.instance_class
#  storage_type = "io1"
#  allocated_storage = 20
#  iops = 1000
  master_username = data.aws_ssm_parameter.DB_ADMIN_USER.value
  master_password = data.aws_ssm_parameter.DB_ADMIN_PASS.value
  db_subnet_group_name = aws_db_subnet_group.default.id
  vpc_security_group_ids = [aws_security_group.rds.id]

}
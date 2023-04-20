resource "aws_instance" "bastion-instance" {
  ami                    = "ami-02f3f602d23f1659d"
  instance_type          = "t2.micro"
  subnet_id              = var.public_subnet_1_id
  vpc_security_group_ids = [var.ecs_sg_id]
  key_name               = var.key_pair_name
  tags = {
    Name = "bastion-instance"
  }
}

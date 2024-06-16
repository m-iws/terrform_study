# ------------------------------------------------------------#
#  EC2
# ------------------------------------------------------------#
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

#IAMロール
resource "aws_iam_role" "s3_role" {
  name               = "${var.tag_name}-s3_role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}


#ポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "role-policy-attachment_ec2_s3_role_policy" {
  role       = aws_iam_role.s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.tag_name}-ec2_instance_profile"
  role = aws_iam_role.s3_role.name
}


resource "aws_instance" "ec2_a" {
  ami                    = "ami-05b37ce701f85f26a"
  instance_type          = "t2.micro"
  key_name               = "terraform01"
  availability_zone      = "${var.region}a"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_id              = aws_subnet.public_sub_a.id
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  tags = {
    Name = "${var.tag_name}-ec2-a"
  }
}

resource "aws_instance" "ec2_c" {
  ami                    = "ami-05b37ce701f85f26a"
  instance_type          = "t2.micro"
  key_name               = "terraform01"
  availability_zone      = "${var.region}a"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_id              = aws_subnet.public_sub_a.id
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  tags = {
    Name = "${var.tag_name}-ec2-c"
  }
}


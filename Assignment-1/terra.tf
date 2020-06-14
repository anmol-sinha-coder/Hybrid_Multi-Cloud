provider "aws" { 
  version = "~> 2.66"
  shared_credentials_file = file("~/.aws/credentials")
  region = "us-east-1"
  profile = "anmol"
}


resource "aws_instance" "web" {
  ami           = "ami-01d025118d8e760db"
  instance_type = "t2.micro"
  key_name = "My_SSH"
  security_groups = [ "launch-wizard-2" ]

  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("~/Desktop/My_SSH.pem")
    host     = aws_instance.web.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd git -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
    ]
  }

  tags = {
    Name = "terraform-automation"
  }

}


resource "aws_ebs_volume" "EBS" {
  availability_zone = aws_instance.web.availability_zone
  size              = 1

  tags = {
    Name = "terraform-automation"
  }
}


resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.EBS.id //"${aws_ebs_volume.EBS.id}"
  instance_id = aws_instance.web.id //"${aws_instance.web.id}"
  force_detach = true
}


output "myos_ip" {
  value = aws_instance.web.public_ip
}


resource "null_resource" "nulllocal2"  {
	provisioner "local-exec" {
	    command = "echo  ${aws_instance.web.public_ip} > publicip.txt"
  	}
}


resource "null_resource" "nullremote3"  {

depends_on = [
    aws_volume_attachment.ebs_att,
  ]


  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("~/Desktop/My_SSH.pem")
    host     = aws_instance.web.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4  /dev/xvdh",
      "sudo mount  /dev/xvdh  /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/anmol-sinha-coder/Hybrid_Multi-Cloud.git /var/www/html/"
    ]
  }
}



resource "null_resource" "nulllocal1"  {


depends_on = [
    null_resource.nullremote3,
  ]

	provisioner "local-exec" {
	    command = "chrome  ${aws_instance.web.public_ip}"
  	}
}



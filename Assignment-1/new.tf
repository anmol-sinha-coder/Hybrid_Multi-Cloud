provider  "aws" {
  version = "~> 2.66"
  shared_credentials_file = file("~/.aws/credentials")
  region  = "ap-south-1"
  profile = "AWS_S3"
}


resource "tls_private_key" "AWS_img_key" {
  algorithm   = "RSA"
  rsa_bits = 4096
}



resource "local_file" "kingston" {
    filename = "My_SSH.pem"
}


resource "aws_key_pair" "AWS_img_key" {
  key_name   = "My_SSH"
  public_key = tls_private_key.AWS_img_key.public_key_openssh  
}



resource "aws_instance"  "AWS_img" {
  ami           = "ami-0447a12f28fddb066"
  instance_type = "t2.micro"
  key_name	=  aws_key_pair.AWS_img_key.key_name
  security_groups =  [ "task_1-sg" ] 
  
connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = tls_private_key.AWS_img_key.private_key_pem
    host     = aws_instance.AWS_img.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd git -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
    ]
  } 

tags = {
    Name = "LinuxWorld"
  }
}

output  "myout_1" {
  value = aws_instance.AWS_img.availability_zone
}


resource "aws_security_group"  "task_1-sg" {
  name = "task_1-sg"
  description = "Allow TCP inbound traffic"
  vpc_id = "vpc-92geh7xy"

 ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol  = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
        }


    ingress {
        description = "HTTP" 
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
        }

  

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        }

  

    tags {
    Name = "task_1-sg"
    }
}



resource "aws_ebs_volume" "volume_1" {
  availability_zone = aws_instance.AWS_img.availability_zone
  size              = 4

    tags = {
        Name = "mynewvolume"
    }
}
 



resource "aws_volume_attachment" "ebsattch" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.volume_1.id
  instance_id = aws_instance.AWS_img.id
  force_detach = true
} 


    output "mine_ebss12" {
        value = aws_ebs_volume.volume_1.id
        }

    output "mineos_ip" {
        value = aws_instance.AWS_img.public_ip
        }

    resource "null_resource" "local_null"  {
        provisioner "local-exec" {
            command = "echo  ${aws_instance.AWS_img.public_ip}  > mypublicip.txt"
  	        }
}



resource "null_resource" "remotenull444" {
        depends_on = [
        aws_volume_attachment.ebsattch,
        ]

        connection {
            type     = "ssh"
            user     = "ec2-user"
            private_key = tls_private_key.AWS_img_key.private_key_pem
            host     = aws_instance.AWS_img.public_ip
        }

        provisioner "remote-exec" {
        inline = [
                "sudo mkfs.ext4  /dev/xvdh",
                "sudo mount  /dev/xvdh  /var/www/html",
                "sudo rm -rf /var/www/html/*",
                "sudo git clone https://github.com/anmol-sinha-coder/Hybrid_Multi-Cloud.git   /var/www/html/"
   
         ]
  
        }

}



resource "aws_s3_bucket" "bin" {
  bucket = "bin"
  acl     = "public-read"
  provisioner "local-exec" {
        command     = "git clone https://github.com/anmol-sinha-coder/Hybrid_Multi-Cloud  AWS_terra"
    }

provisioner "local-exec" {
        when        =   destroy
        command     =   "echo Y | rmdir /s  AWS_terra"
    }

}

resource "aws_s3_bucket_object" "image-pull"{
  bucket  = aws_s3_bucket.bin.bucket
  key     = "new.jpg"
  source  = "AWS_terra/hello.png"
  acl     = "public-read"
}


//cloud front
locals {
s3_origin_id = aws_s3_bucket.bin.bucket
image_url = "${aws_cloudfront_distribution.s3_distribution.domain_name}/${aws_s3_bucket_object.image-pull.key}"

}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.bin.bucket_regional_domain_name 
    origin_id   = local.s3_origin_id 

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/F306Z4BT6QVHCN" 
    }
  }


  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "Hybrid_Multi-Cloud/Assignment-1/Multi-color.htm" 


default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }


viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

    viewer_certificate {
        cloudfront_default_certificate = true
      }

    connection {
    
    type     = "ssh"
    
    user     = "ec2-user"
    
    private_key = tls_private_key.AWS_img_key.private_key_pem
    host     = aws_instance.AWS_img.public_ip
  
    }

    provisioner "remote-exec" {
            inline  = [
                "sudo su << EOF",
                "echo \"<img src='http://${self.domain_name}/${aws_s3_bucket_object.image-pull.key}'>\" >> /var/www/html/Hybrid_Multi-Cloud/Assignment-1/Multi-color.htm",
                "EOF"
            ]
        }

    }




    resource "null_resource" "localnull_2"  {
    depends_on = [
    aws_cloudfront_distribution.s3_distribution,
     ]

    provisioner "local-exec" {	    
    command = "start chrome  ${aws_instance.AWS_img.public_ip}"
    }

}


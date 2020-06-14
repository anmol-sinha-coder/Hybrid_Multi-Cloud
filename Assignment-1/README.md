# <img src="https://www.terraform.io/assets/images/og-image-8b3e4f7d.png" height=200 width=200></img> Terraform - AWS - Jenkins <img src="https://futurumresearch.com/wp-content/uploads/2020/01/aws-logo.png" height=200 width=300> </img>

Terraform is an open-source infrastructure as code (IAC) software tool created by HashiCorp. It enables users to define and provision a datacenter infrastructure using a high-level configuration language known as Hashicorp Configuration Language (HCL), or optionally JSON.Terraform supports a number of cloud infrastructure providers such as Amazon Web Services, IBM Cloud (formerly Bluemix), Google Cloud Platform, DigitalOcean, Linode, Microsoft Azure, Oracle Cloud Infrastructure, OVH, Scaleway, VMware vSphere or Open Telekom Cloud as well as OpenNebula and OpenStack. Terraform is created in Google's Go language, with its latest stable version being 0.12.26/May27-2020.
_________________________________________________________________________________________________________________________
![terra](https://www.terraform.io/assets/images/docs/registry-publish-14c12da0.gif)
## Procedure
* Here we plan on using Programming Documentation based multi-cloud architecture to deploy the products with AWS as provider.
* The first step would be credentials validation, for reference use --> [click here](https://www.terraform.io/docs/providers/aws/index.html)
* It is essential to keep track of correct JSON like syntax of the **'*.tf'** file which we shall create, for reference-->[click here](https://www.terraform.io/docs/configuration/syntax.html)
* Further use of terraform keywords like 'resources', 'provisioner', instance_type and others a document is created with reference link-->[click here](https://www.terraform.io/docs/configuration/resources.html)
* Often providing ouput is essential, and the right keywords must be known; for reference -->[click here](https://www.terraform.io/docs/configuration/outputs.html)
* An EBS volume must also be provided like a default external hard-disk for the system. The resource can be mentioned as follows -->[click here](https://www.terraform.io/docs/providers/aws/r/ebs_volume.html)
<img src="https://www.parkmycloud.com/wp-content/uploads/terraform-x-aws-1.png" height=200 width=300> </img>
* Now that the essential websites ave been covered, it is essential that one must write the terraform code. Create a file **terra.tf** or any file name you want. Use a basic text editor type out the following :-
___________________________________________________________________________________________________________________________

	provider "aws" { 
	  version = "~> 2.66"
	  shared_credentials_file = file("~/.aws/credentials")
	  region = "us-east-1"
	  profile = "anmol" // any name would do here
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
_____________________________________________________________________________________________________________________________
* Ensure that your installed **terraform.exe** is in environment variables (for Windows-10). If not, type *Windows*+*R* keys to execute *Run*. Type 'sysdm.cpl' in the input box. In the appearing dialog box, go to advanced tab (top middle), and then go to 'Environment Variables' in the bottom right.
* Finally go to the *User Variables* option **Path** and create a new variable. Add the current location of the 'terraform.exe' file into the input bar at the bottom of Path dialog box. Click OK to save.
* Now save the file in a new directory (preferably). Lets call this directory 'TF'. Now we must initialize the directory. Then check for correctness of code. Finally we have to run the code. In the future destroying of code may be necessary, as well.
```diff
# terraform init
# terraform validate
# terraform apply

# terraform destroy
```
* Everything should work correctly, refer the screenshots for any necessary reference. I have used PuTTy software to run SSH on my Redhat_Linux type OS running on AWS.
* Congratulations, you have just implemented a Multi-cloud architecture platform, with the use of structured frameworks such as Apche WebServer(httpd) and Centralized Version Control System (CVCS) git.
* Mind the dependencies, which ensure the order of execution of tasks. You cannot have a repository cloned into your local system without there existing a memory-disk in the first place !
* How about going one step further? Have your own Linux (**Fedora-** Redhat/CentOS) (**Debian-** Ubuntu/Debian_GNU), then you can run Jenkins easily to execute your created *'terra.tf'* file. This will work with both VM(Virtual Machine) running on VirtualBox or VMWare, as well as, Dual (or Multiple) Boot.
* Instead of Poll SCM, use of Github's Webhooks would be better to trigger builds. Use of CI/CD to automate tasks helps industries better.
	<img src="https://www.edureka.co/blog/wp-content/uploads/2016/11/Jenkins-4.gif" width=400 height=300></img>
* Now lets create Security Groups, reroute TCP traffic, such as HTTP, for reference -->[click here](https://www.terraform.io/docs/providers/aws/r/security_group.html)
* Amazon Simple Storage Service is storage for the Internet. It is designed to make web-scale computing easier for developers. -->[click here](https://www.terraform.io/docs/providers/aws/r/s3_bucket.html)
* Essentially one can use image, video and other static files for S3, while DynamoDB is used for Relational Database storage.-->[click here](https://www.terraform.io/docs/providers/aws/r/dynamodb_table.html)
* Further use of Cloud Front services in AWS ensures global connectivity and faster solutions for clients via use of cache files stored at the EDGE location nearest to original Data Centre.For reference -->[click here](https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html)
* Now, we have our documentation code, for your help. The following file is called 'new.tf', and here it is:-
_________________________________________________________________________________________________________________

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



	resource "local_file" "auth" {
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



_________________________________________________________________________________________________________________
<img src="https://d2908q01vomqb2.cloudfront.net/ca3512f4dfa95a03169c5a670a4c91a19b3077b4/2019/12/14/Architecture2.png" width=800 height=400> </img>
## Summary and Conclusion:

[1] Recap of the '.tf' file keywords like 'resource', 'variable', 'output'.

[2] Discussion of 'provisioner' in terraform to run command prompt /shell script commands.

[3] Explanation of provisioner's Necessity to work inside resource blocks.

[4] Use of null resource in running a provisioner in the local system.

[5] Discussion on types of provisioner - remote and local, to execute arguments for system shells or reverse shells in remote system.

[6] Use of terraform docs, to look for syntax of instances and configuration.

[7] Discussion on complete automation of cloud based activities by use of terraform.

[8] Basic use of terraform commands 'init', 'validate', 'apply' , and 'delete'.

[9] Explanation of Necessity to make the terraform and the private/public cloud like AWS, capable of both creation as well as destruction of the architecture.

[10] Use of terraform arguments like 'auto-approve' to prevent need of user's presence while automating via Jenkins.

[11] Use of 'force-delete' assignment to 'True' for real time use in testing environment for an EBS Volume.

[12] Concept of devices, partitioning, and mounting, and explanation of device as being busy/used when mounted.

[13] Concept of dependency in terraform to prevent resources being pulled from github/CVCS before actual Volume/memory disk creation.

[14] Automation with Jenkins using Github-Webhooks and posting file pushed information to *JENKINS_URL/github-webhook* for CI/CD with automated frameworks.

```diff
----------------------------------------------------------------------------------------------------------
! Author :
+  Anmol Sinha | 1805553@kiit.ac.in
```

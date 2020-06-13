# <img src="https://www.terraform.io/assets/images/og-image-8b3e4f7d.png" height=200 width=200> Terraform 

Terraform is an open-source infrastructure as code software tool created by HashiCorp. It enables users to define and provision a datacenter infrastructure using a high-level configuration language known as Hashicorp Configuration Language (HCL), or optionally JSON.Terraform supports a number of cloud infrastructure providers such as Amazon Web Services, IBM Cloud (formerly Bluemix), Google Cloud Platform, DigitalOcean, Linode, Microsoft Azure, Oracle Cloud Infrastructure, OVH, Scaleway, VMware vSphere or Open Telekom Cloud as well as OpenNebula and OpenStack. Terraform is created in Google's Go language, with its latest stable version being 0.12.26/May27-2020.
_________________________________________________________________________________________________________________________
![terra](https://www.terraform.io/assets/images/docs/registry-publish-14c12da0.gif)
## Procedure
* Here we plan on using Programming Documentation based multi-cloud architecture to deploy the products with AWS as provider.
* The first step would be credentials validation, for reference use --> [click here](https://www.terraform.io/docs/providers/aws/index.html)
* It is essential to keep track of correct JSON like syntax of the **'*.tf'** file which we shall create, for reference-->[click here](https://www.terraform.io/docs/configuration/syntax.html)
* Further use of terraform keywords like 'resources', 'provisioner', instance_type and others a document is created with reference link-->[click here](https://www.terraform.io/docs/configuration/resources.html)
* Often providing ouput is essential, and the right keywords must be known; for reference -->[click here](https://www.terraform.io/docs/configuration/outputs.html)
* An EBS volume must also be provided like a default external hard-disk for the system. The resource can be mentioned as follows -->[click here](https://www.terraform.io/docs/providers/aws/r/ebs_volume.html)
<img src="https://www.parkmycloud.com/wp-content/uploads/terraform-x-aws-1.png" height=200 width=300>
* Now that the essential websites ave been covered, it is essential that one must write the terraform code. Create a file **terra.tf** or any file name you want. Use a basic text editor type out the following :-
___________________________________________________________________________________________________________________________

		// Terraform code
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
* Now save the file in 

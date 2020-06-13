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
* How about going one step further? Have your own Linux (**Fedora-** Redhat/CentOS)(**Debian-** Ubuntu/Debian_GNU), then you can run Jenkins easily to execute your created 'terra.tf' file.
* Instead of Poll SCM, use of Github's Webhooks would be better to trigger builds.
<img src="https://www.edureka.co/blog/wp-content/uploads/2016/11/Jenkins-4.gif" width=300 height=200></img>
_________________________________________________________________________________________________________________
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

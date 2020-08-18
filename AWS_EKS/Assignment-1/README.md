# <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/Amazon_Web_Services_Logo.svg/1280px-Amazon_Web_Services_Logo.svg.png" width=150 height=100>AWS EKS <img src="https://www.bluematador.com/hs-fs/hubfs/www/Icons/bluematador-aws-EKS.png?width=200&name=bluematador-aws-EKS.png" height=100 width=100>

## click through AWS console to create EFS
login to AWS console and search for service _EFS_   
click through wizard , use our course VPC and all 3 AZs
*specify the security group of your EC2-worker-nodes, to be applied to EFS as well*
<img src ="https://www.altoros.com/blog/wp-content/uploads/2020/03/AWS-Fargate-on-ECS-and-EKS-v4.gif"></img>

## add amazon-efs-utils
install the package *amazon-efs-utils* on all worker nodes

Used technologies like fargate via Amazon web services.
```
ssh -i <<eks-course.pem>> ec2-user@<<ec2-workernode>> "sudo yum install -y amazon-efs-utils"
```
# <img src="https://www.datocms-assets.com/2885/1506458597-blog-terraform-list.svg" width=200 height=300></img> Integration
Lets work with terraform....after all, documentated codng using JSON format of coding (Here we call it HashiCorp Language or HCL) is easier to understand and implement. For reference you must look for the following documents:-

* For using the basic EKS cluster, which manages and controls AWS k8s --> [click here](https://www.terraform.io/docs/providers/aws/r/eks_cluster.html)

* For using the EKS Fargate, which provides on-demand, right-sized compute capacity for containers that run as Kubernetes pods --> [click here](https://www.terraform.io/docs/providers/aws/r/eks_fargate_profile.html)

* For using the EKS Node Group, used for auto-scaling the Kubernetes cluster in AWS --> [click here](https://www.terraform.io/docs/providers/aws/r/eks_node_group.html)
```
    provider "aws" {
            region = "ap-south-1"
      profile = "attriprofile"
    }


    //Creating Variable for VPC

    variable "vpc" {
      type    = string
      default = "vpc-dde2ffb5"
    }

    //Creating Key
    resource "tls_private_key" "tls_key" {
      algorithm = "RSA"
    }

    //Generating Key-Value Pair
    resource "aws_key_pair" "generated_key" {
      key_name   = "eks-key"
      public_key = tls_private_key.tls_key.public_key_openssh

      depends_on = [
        tls_private_key.tls_key
      ]
    }

    //Saving Private Key PEM File
    resource "local_file" "key-file" {
      content  = tls_private_key.tls_key.private_key_pem
      filename = "eks-key.pem"

      depends_on = [
        tls_private_key.tls_key
      ]
    }

    //Creating Security Group For NodeGroups

    resource "aws_security_group" "NodeGroup-SecurityGroup" {
      name        = "NodeGroup-SecurityGroup"
      description = "NodeGroupSG"
      vpc_id      = var.vpc


      //Adding Rules to Security Group 

      ingress {
        description = "SSH Rule"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }


      ingress {
        description = "HTTP Rule"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }


      egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }


    //Getting all Subnet IDs of a VPC

    data "aws_subnet_ids" "Subnet" {
      vpc_id = var.vpc
    }


    data "aws_subnet" "Subnet1" {
      for_each = data.aws_subnet_ids.Subnet.ids
      id       = each.value


      depends_on = [
        data.aws_subnet_ids.Subnet
      ]
    }


    //Creating IAM Role for EKS Cluster

    resource "aws_iam_role" "EKS-Role" {
      name = "My-AWS-EKS-Cluster-Role"


    // Policy

      assume_role_policy = <<POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "eks.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }
    POLICY
    }


    //Attaching Polices to IAM Role for EKS

    resource "aws_iam_role_policy_attachment" "IAM-AmazonEKSClusterPolicy" {
      policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
      role       = aws_iam_role.EKS-Role.name
    }


    resource "aws_iam_role_policy_attachment" "IAM-AmazonEKSServicePolicy" {
      policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
      role       = aws_iam_role.EKS-Role.name
    }

    //Created IAM Role for Node Groups

    resource "aws_iam_role" "NG-Role" {
      name = "My-AWS-EKS-NG-Role"

      assume_role_policy = jsonencode({
        Statement = [{
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "ec2.amazonaws.com"
          }
        }]
        Version = "2012-10-17"
      })
    }

    //Attaching Policies to IAM Role of Node Groups

    resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
      policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
      role       = aws_iam_role.NG-Role.name
    }

    resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
      policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
      role       = aws_iam_role.NG-Role.name
    }

    resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
      policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      role       = aws_iam_role.NG-Role.name
    }


    //Creating EKS Cluster

    resource "aws_eks_cluster" "EKSCluster" {
      name     = "My-AWS-EKS-Cluster"
      role_arn = aws_iam_role.EKS-Role.arn


      vpc_config {
        subnet_ids = [for s in data.aws_subnet.Subnet1 : s.id if s.availability_zone != "ap-south-1a"]
      }


      depends_on = [
        aws_iam_role_policy_attachment.IAM-AmazonEKSClusterPolicy,
        aws_iam_role_policy_attachment.IAM-AmazonEKSServicePolicy,
        data.aws_subnet.Subnet1
      ]
    }

    //Creating a Node Group 1

    resource "aws_eks_node_group" "NG1" {
      cluster_name    = aws_eks_cluster.EKSCluster.name
      node_group_name = "Node-Group1"
      node_role_arn   = aws_iam_role.NG-Role.arn
      subnet_ids      = [for s in data.aws_subnet.Subnet1 : s.id if s.availability_zone != "ap-south-1a"]

      scaling_config {
        desired_size = 1
        max_size     = 2
        min_size     = 1
      }

      instance_types  = ["t2.micro"]

      remote_access {
        ec2_ssh_key = "eks-key"
        source_security_group_ids = [aws_security_group.NodeGroup-SecurityGroup.id]
      }

      depends_on = [
        aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
        aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
        aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
        aws_eks_cluster.EKSCluster
      ]
    }

    //Creating Node Group 2

    resource "aws_eks_node_group" "NG2" {
      cluster_name    = aws_eks_cluster.EKSCluster.name
      node_group_name = "Node-Group2"
      node_role_arn   = aws_iam_role.NG-Role.arn
      subnet_ids      = [for s in data.aws_subnet.Subnet1 : s.id if s.availability_zone != "ap-south-1a"]

      scaling_config {
        desired_size = 1
        max_size     = 2
        min_size     = 1
      }

      instance_types  = ["t2.micro"]

      remote_access {
        ec2_ssh_key = "eks-key"
        source_security_group_ids = [aws_security_group.NodeGroup-SecurityGroup.id]
      }

      depends_on = [
        aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
        aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
        aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
        aws_eks_cluster.EKSCluster
      ]
    }


    //Updating Kubectl Config File
    resource "null_resource" "Update-Kube-Config" {
      provisioner "local-exec" {
        command = "aws eks update-kubeconfig --name My-AWS-EKS-Cluster"
      }
      depends_on = [
        aws_eks_node_group.NG1,
        aws_eks_node_group.NG2
      ]
    }
```
# Getting Started
### Some Pre-Requisites:
You need to have an AWS account. It cannot be the Starter Program since EKS is not supported there. Secondly, you must have a basic knowledge of AWS and Kubernetes. Third, you must have AWS CLI set up in your system with a dedicated profile allowing ADMIN Access so that it can directly use the EKS.

Although AWS CLI provides commands to manage EKS, but they are not efficient enough to perform complex tasks. Therefore, we are going to use another CLI built especially for EKS. Apart from that, we need to have kubectl installed in our system too, for communicating with the Pods running on EKS. It is a managed service so everything will be managed by it except kubectl command because it is a client program, which will help us to connect with the pods.

## Starting the EKS Cluster

To start the EKS cluster, we need to set up a YAML file containing the infrastructure of the cluster. Information like the number of Worker Nodes, allowed EC2 instances, AWS key for connecting the instances with our local terminal and many more, are mentioned in this file.

After we write the desired infrastructure in our YAML file, we will have to execute the file with the EKSCTL CLI we have installed.

    $ eksctl create cluster -f cluster.yaml
    
## Setting up the kubectl CLI

After the cluster is launched, we need to connect our system with the pods so that we can work on the cluster. Kubernetes has been installed in the instances already by EKS. Therefore to connect our kubectl with the Kubernetes on the instances, we need to update the KubeConfiguration file first. For this, we use the following command:

    aws eks update-kubeconfig  --name cluster1

We can check the connectivity with the command: 'kubectl cluster-info'
For finding the number of nodes: 'kubectl get nodes'

For finding the number of pods: 'kubectl get pods'

To get detailed information of the instances on which the pods are running: kubectl get pods -o wide

Before we work, we need to create a namespace for our application in the K8s.

For that we use the following command: kubectl create namespace wp-msql

Now we have to set it to be the default Namespace:

    kubectl config set-context --current --namespace=wp-msql

For checking how many pods is running inside the namespace ‘kube-system’ we have to execute : kubectl get pods -n kube-system
Installing WordPress and MySQL

Now, we are ready to install WordPress and Mysql in our cluster. For that, we need to copy the 3 files given below in a folder.

This file contains information about the different settings to be applied to our MySQL pod.

Similarly, this file contains information about the different settings to be applied to our WordPress pod.

At last, we create a Kustomization file to specify the order of execution of the files along with the secret keys.

After putting the above scripts in a folder, we can build the infrastructure using the following command: 'kubectl create -k'

Our WordPress server along with MySQL is now launched in the EKS!

To customize the site, we need a URL to visit. For that, we will be using the Public DNS provided by the External Load Balancer (ELB).

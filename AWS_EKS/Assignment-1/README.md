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

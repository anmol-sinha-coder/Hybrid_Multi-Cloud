# <img src=https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/Amazon_Web_Services_Logo.svg/1280px-Amazon_Web_Services_Logo.svg.png height=40 width=80> Elastic Kubernetes Service
<img src="https://raw.githubusercontent.com/DataDog/integrations-core/master/amazon_eks/images/amazon_eks_dashboard.png" height=400 width=800>
Amazon Elastic Kubernetes Service (Amazon EKS) is a managed service that makes it easy for you to run Kubernetes on AWS without needing to stand up or maintain your own Kubernetes control plane. Kubernetes is an open-source system for automating the deployment, scaling, and management of containerized applications.

Amazon EKS runs Kubernetes control plane instances across multiple Availability Zones to ensure high availability. Amazon EKS automatically detects and replaces unhealthy control plane instances, and it provides automated version upgrades and patching for them.

Amazon EKS is also integrated with many AWS services to provide scalability and security for your applications, including the following:

`1`Amazon ECR for container images

`2`Elastic Load Balancing for load distribution

`3`IAM for authentication

`4`Amazon VPC for isolation

Amazon EKS runs up-to-date versions of the open-source Kubernetes software, so you can use all the existing plugins and tooling from the Kubernetes community. Applications running on Amazon EKS are fully compatible with applications running on any standard Kubernetes environment, whether running in on-premises data centers or public clouds. This means that you can easily migrate any standard Kubernetes application to Amazon EKS without any code modification required. 
____________________________________________________________________________________________________________________________________________________
Whenever it comes to create a website for any freelancing or business, WordPress was and is the first choice for millions of developers. Although the backend service stills use PHP even when advanced tools like Node.js, Django have revolutionized the ways for creating interactive and dynamic Web Applications.

The main reason as far I understand is the simplicity and fast development process. You do not have to be a Full Stack developer to create a website for a local grocery shop or a small business. WordPress is built in such a way that with a few button clicks, you are ready with a basic website. All these benefits portray how it still the Market Leader among other Content Management Systems, even after nearly 2 decades of its launch.

# A Step Towards Containerized Deployment

Containerization or the ability to build containers around any applications has changed the way deployment takes place in the age of Cloud-Ops. The concept of building containers has solved different kinds of problems faced in the traditional approach of deploying applications, mostly security and portability. Docker, Podman and Cri-o are some of the tools which manage the procedure of creating containers for applications. Once containers are created, they can be run on any system irrespective of their configuration apart from the hardware requirements. Running Dockerized applications require just a single line of code to start the containers!
<img src="https://miro.medium.com/max/600/1*iCKRQHks0RX0loqUkcc-rg.png">


Till now, it seems nice! But now imagine a situation where you are building a large application, preferably a Web Application with a dedicated frontend and a backend. Now you wish to follow a micro-service based architecture where you will be dockerizing the frontend and backend of the applications separately in different containers and then connecting them with different REST APIs. At this time, you have to handle 2 containers simultaneously. You have to make sure both the containers are running all the time and if any container crashes, you have to manually restart the services. The process further complicates when you are trying to create some more microservices to add more features to your container. At last, you will find it very difficult to handle and manage all containers together.

# The need for Container Orchestration Services

Wouldn’t be it better if there’s a service which is continuously running in the background and is managing all the containers together? Whenever a container crashes, it would automatically re-launch it and when the traffic to the website increases, instantly it will scale up the infrastructure by deploying more containers to balance the load.
<img src="https://miro.medium.com/max/792/1*MJsy2bQcs1ttstltT0DLXA.png">

In Kubernetes, the atomic unit of scheduling in Pod. Pods are slightly different from containers. We can run multiple containers in a single pod but not vice-versa. This comes very conveniently when we have containers which are fully dependent on each other, e.g. WordPress and MySQL are dependent since all data from WordPress would be stored in MySQL.
Understanding the Architecture of Kubernetes
<img src="https://miro.medium.com/max/840/1*gF9c3FRuqlamdqAMtVVkGA.png">

Whenever we work with K8s, we at first have to create a cluster. A cluster contains a Master node and several Worker nodes or slaves.

The job of the Master Node is to schedule and monitor the logs of the containers running inside the pods, present inside the Worker Nodes. Whenever a client requests a Pod to be launched to the Master, the client connects to the API server at port 6443 of the master. Then the Master takes the client request to the Kubelet program present at the Worker Nodes. Based on the request, the Kubelet program communicates with internal docker engine to perform the required job.

Some of the other services running across the cluster:
<br/>[*]On Master Nodes:

    etcd: It stores the configuration information which can be used by each of the nodes in the cluster. Here the Master store permanent data like secrets i.e key-value information, config files etc.
    API Server: Kubernetes is an API server which provides all the operation on the cluster using the API.
    Controller Manager: This component is responsible for most of the collectors that regulate the state of the cluster and performs a task.
    Scheduler: Responsible for workload utilization and allocating pod to the new node.

[*]On Worker Nodes:

    Docker: The first requirement of each node is Docker which helps in running the encapsulated application containers in a relatively isolated but lightweight operating environment.
    Kubelet Service: This is a small service in each node responsible for relaying information to and from control plane service. It interacts with etcd store to read configuration details and wright values.
    Kubernetes Proxy Service: This is a proxy service which runs on each node and helps in making services available to the external host.

Kubernetes — Architecture
www.tutorialspoint.com

When running a Kubernetes cluster, one of the foremost challenges is deciding which cloud or datacenter it’s going to be deployed to. After that, you still need to filter your options when selecting the right network, user, storage, and logging integrations for your use cases.
Benefits of Amazon EKS: Why use EKS?

Through EKS, normally cumbersome steps are done for you, like creating the Kubernetes master cluster, as well as configuring service discovery, Kubernetes primitives, and networking. Existing tools will more than likely work through EKS with minimal mods, if any.
Image for post
Image for post

With Amazon EKS, the Kubernetes Control plane — including the backend persistence layer and the API servers — is provisioned and scaled across various AWS availability zones, resulting in high availability and eliminating a single point of failure. Unhealthy control plane nodes are detected and replaced, and patching is provided for the control plane. The result is a resilient AWS-managed Kubernetes cluster that can withstand even the loss of an availability zone.

And of course, as part of the AWS landscape, EKS is integrated with various AWS services, making it easy for organizations to scale and secure applications seamlessly. From AWS Identity Access Management (IAM) for authentication to Elastic Load Balancing for load distribution, the straightforwardness and convenience factor of using EKS can’t be understated.

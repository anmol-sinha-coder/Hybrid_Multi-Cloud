# Hybrid Cloud/GCP
Deploying WordPress with MySQL on Top of Google Cloud Platform
A brief explanation of different tools and services used along with a complete walkthrough of the installation process
_______________________________________________________________________
Whenever it comes to create a website for any freelancing or business, WordPress was and is the first choice for millions of developers. Although the backend service stills use PHP even when advanced tools like Node.js, Django have revolutionized the ways for creating interactive and dynamic Web Applications.

The main reason as far I understand is the simplicity and fast development process. You do not have to be a Full Stack developer to create a website for a local grocery shop or a small business. WordPress is built in such a way that with a few button clicks, you are ready with a basic website. All these benefits portray how it still the Market Leader among other Content Management Systems, even after nearly 2 decades of its launch.
<img src="https://miro.medium.com/max/1500/1*GH_UPEc_4jhDHuhHGMSU4Q.png" width=1000 height=600>
## A Move Towards Containerized Deployment

Containerization or the ability to build containers around any applications has changed the way deployment takes place in the age of Cloud-Ops. The concept of building containers has solved different kinds of problems faced in the traditional approach of deploying applications, mostly security and portability. Docker, Podman and Cri-o are some of the tools which manage the procedure of creating containers for applications. Once containers are created, they can be run on any system irrespective of their configuration apart from the hardware requirements. Running Dockerized applications require just a single line of code to start the containers!

Till now, it seems nice! But now imagine a situation where you are building a large application, preferably a Web Application with a dedicated frontend and a backend. Now you wish to follow a micro-service based architecture where you will be dockerizing the frontend and backend of the applications separately in different containers and then connecting them with different REST APIs. At this time, you have to handle 2 containers simultaneously. You have to make sure both the containers are running all the time and if any container crashes, you have to manually restart the services. The process further complicates when you are trying to create some more microservices to add more features to your container. At last, you will find it very difficult to handle and manage all containers together.
The need for Container Orchestration Services

Wouldn’t be it better if there’s a service which is continuously running in the background and is managing all the containers together? Whenever a container crashes, it would automatically re-launch it and when the traffic to the website increases, instantly it will scale up the infrastructure by deploying more containers to balance the load.


In Kubernetes, the atomic unit of scheduling in Pod. Pods are slightly different from containers. We can run multiple containers in a single pod but not vice-versa. This comes very conveniently when we have containers which are fully dependent on each other, e.g. WordPress and MySQL are dependent since all data from WordPress would be stored in MySQL.
Understanding the Architecture of Kubernetes
![k8s](https://miro.medium.com/max/750/1*g0FHR4a0HOFIGLdSdwUvEw.png)

Whenever we work with K8s, we at first have to create a cluster. A cluster contains a Master node and several Worker nodes or slaves.

The job of the Master Node is to schedule and monitor the logs of the containers running inside the pods, present inside the Worker Nodes. Whenever a client requests a Pod to be launched to the Master, the client connects to the API server at port 6443 of the master. Then the Master takes the client request to the Kubelet program present at the Worker Nodes. Based on the request, the Kubelet program communicates with internal docker engine to perform the required job.

Some of the other services running across the cluster:
On Master Nodes:

    etcd: It stores the configuration information which can be used by each of the nodes in the cluster. Here the Master store permanent data like secrets i.e key-value information, config files etc.
    API Server: Kubernetes is an API server which provides all the operation on the cluster using the API.
    Controller Manager: This component is responsible for most of the collectors that regulate the state of the cluster and performs a task.
    Scheduler: Responsible for workload utilization and allocating pod to the new node.

On Worker Nodes:

    Docker: The first requirement of each node is Docker which helps in running the encapsulated application containers in a relatively isolated but lightweight operating environment.
    Kubelet Service: This is a small service in each node responsible for relaying information to and from control plane service. It interacts with etcd store to read configuration details and wright values.
    Kubernetes Proxy Service: This is a proxy service which runs on each node and helps in making services available to the external host.

## Kubernetes - Architecture
In this chapter, we will discuss the basic architecture of Kubernetes. As seen in the following diagram, Kubernetes…
www.tutorialspoint.com

When running a Kubernetes cluster, one of the foremost challenges is deciding which cloud or datacenter it’s going to be deployed to. After that, you still need to filter your options when selecting the right network, user, storage, and logging integrations for your use cases.
What is Cloud Computing?

Cloud computing is the on-demand delivery of computing power, database storage, applications, and other IT resources through a cloud services platform via the internet with pay-as-you-go pricing. It is the use of remote servers on the internet to store, manage and process data rather than a local server or your personal computer.
![kuber-docker](https://miro.medium.com/max/1050/1*Di_7RpbqUf3RSht6gl8A7A.png)

Cloud computing allows companies to avoid or minimize up-front IT infrastructure costs to keep their applications up and running faster, with improved manageability and less maintenance, and that it enables IT, teams, to adjust resources rapidly to meet fluctuating and unpredictable demand.

Cloud-computing providers offer their services according to different models, of which the three standard models per NIST (National Institute of Standards and Technology ) are :

    Infrastructure as a Service (IaaS)
    Platform as a Service (PaaS), and
    Software as a Service (SaaS)

Image for post
Image for post
## Why Google Cloud Platform?

Google Cloud Platform, is a suite of cloud computing services that run on the same infrastructure that Google uses internally for its end-user products, such as Google Search, Gmail, Google Photos and YouTube. We all know how big is the database of Gmail, Youtube and Google Search.
Google Cloud Platform Regions and Zones

Google Cloud Platform services are available in various locations across North America, South America, Europe, Asia, and Australia. These locations are divided into regions and zones. You can choose where to locate your applications to meet your latency, availability and durability requirements.

### What are Google Cloud Platform (GCP) Services?

Google offers a wide range of Services. Following are the major Google Cloud Services:

    Compute
    Networking
    Storage and Databases
    Big Data
    Machine Learning
    Identity & Security
    Management and Developer Tools


### Getting Started
Some Pre-Requisites:
What we will perform?

    Create two projects on GCP as two different team managing frontend and backend.
    Creating VPC on both the project and peering them.
    On the backend VPC, we will set the MySql database using SQL service.
    On the frontend VPC, we will set the Kubernetes Cluster and then deploy WordPress on top of it connecting it with backend.

Creating two projects and VPC inside them
Project 1: Frontend with WordPress

## Google Cloud SQL

Google Cloud SQL is a MySQL database that lives in Google Cloud and doesn’t require any software installation and maintenance since it is provided as a service by Google Cloud so it’s maintained, managed and administered by Google Cloud itself. Just as regular MySQL database, Google Cloud SQL also lets you create, modify, configure and utilize a relational database.
!(cloud)https://miro.medium.com/max/1050/1*ICTx9Hmhp5PEUuJUn-9VQw.png

### Features of Google Cloud SQL
Google Cloud SQL easily lets you move your MySQL databases on the cloud and gives you a similar interface to work with. Some other features of Google Cloud SQL are:

    Easy to Use: Google Cloud SQL has an intuitive and graphical user interface which lets you go about building your database instances with just a click of a mouse, sparing you from having to remember a series of complicated commands.
    Maintained by Google: Google Cloud SQL is fully managed by Google so, you get your data management tasks such as patch management, replication and other similar tasks handled by Google.
    Highly Available: Google stands true to the promise to make your data available to you no matter what happens to a data centre.
    Compatibility with other Google Cloud Services: You can use Google Cloud SQL with just about any other service offered by Google cloud as well as with your favourite Google products such as Google sheet without having to worry about the configurations and installations.
    Security: Google manages the updated and automated backups of your data along with providing the top-notch security advancements for your databases. So even if there is a major failure or data breaching threat, your data is always secure and your database is always available.

## Creating MySQL instance on GCP SQL service

Using the intuitive and graphical user interface, let's create our database.
![hello](https://miro.medium.com/max/750/1*nnfeGTuAg7j9iO8_MSTr8A.png)

We select MySQL from the option since we are going to use it in our WordPress.


We complete the rest of the setup by following on-screen instructions.


Back from the CLI, we enter the username and password set for the DB, to login and create the database.

```diff
# gcloud sql databases create <name> --instance=<sql instance name>
```
## Google Kubernetes Engine (GKE)

Google Kubernetes Engine (GKE) provides a managed environment for deploying, managing, and scaling your containerized applications using Google infrastructure. The GKE environment consists of multiple machines (specifically, Compute Engine instances) grouped together to form a cluster.

GKE clusters are powered by the Kubernetes open-source cluster management system. Kubernetes provides the mechanisms through which you interact with your cluster. You use Kubernetes commands and resources to deploy and manage your applications, perform administration tasks, set policies, and monitor the health of your deployed workloads.

Kubernetes draws on the same design principles that run popular Google services and provides the same benefits: automatic management, monitoring and liveness probes for application containers, automatic scaling, rolling updates, and more. When you run your applications on a cluster, you’re using technology based on Google’s 10+ years of experience running production workloads in containers.

### Launching a Kubernetes Cluster on GCP
Similar to the GCP SQL web portal, the GKE portal is also fairly easy to use. Just by following the instructions provided along, we can easily launch a multinode Cluster.
![GCP_basic](https://storage.googleapis.com/gweb-cloudblog-publish/original_images/3_s5ep0wl.gif)

We will see one cluster created. Click on connect and a pop-up will come which will give a command which we need to run either in cloud shell or on the local terminal if we have kubectl.exe

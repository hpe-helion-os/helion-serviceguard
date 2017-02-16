# Serviceguard Heat Templates
This Readme document contains information on the usage of 
Serviceguard Heat Templates in a cloud environment.

## Readme Document Contents
1.  Introduction to Cloud Maps
2.  Package Contents
3.  Software and Hardware Requirements
4.  Instructions to access cloud environment
5.  Instructions to create and upload Operation System image
6.  Instructions to upload Serviceguard for Linux Image to glance repository
7.  Deploy Serviceguard for Linux Quorum Server using Heat Templates
8.  Deploy Serviceguard clusters using Serviceguard Heat Templates

#### 1. Introduction to Cloud Maps

A Cloud Map is a set of pre-designed templates, work-flows, and scripts that
can be used to deploy and manage server, storage, and network resources as a 
service for specific software applications.

Cloud Maps allow you to orchestrate the creation of application environments 
for HPE CloudSystem and HPE Cloud Service Automation. 

High availability (HA) Cloud Maps provide the fastest way to create new 
infrastructural services that provides continuity for the business applications 
by preventing single point of failures (SPOF). Continuity of services running 
on the instances created with the help of a Cloud Map is ensured through the 
installation of the product HPE Serviceguard for Linux and creating a cluster 
to monitor the resources for failure and providing High-Availability.

Serviceguard Heat Templates are based on the HPE Helion Heat Orchestration 
Templates. They are structured YAML text files. These files are used to 
declare/define the resources and explain the relationship between the resources 
required for the deployment. Heat reads these templates and creates a "stack". 
A Stack is a set of resources which will be created based on the inputs in the 
template. 

#### 2. Package Contents
The Serviceguard Heat Templates repository contains configuration files, scripts 
and sample heat templates to orchestrate deployment of Serviceguard cluster creation.

On the controller node perform the following tasks:
```sh
 Create a new directory For Ex: "/root/sglx".
	mkdir /root/sglx
```
The directory structure post cloning of the Serviceguard Heat Templates git repository is shown below.

       sglx:
       ├───sg_cluster
       │   ├───sgcluster.bash
       │   ├───clusterconfig
       │   ├───Example_SG_Cluster_Template
       │       ├───2_node_cluster.yaml
       │       ├───4_node_cluster.yaml
       │
       ├───sg_quorum
       │   ├───quorum.bash
       │   ├───quorumconfig
       │   ├───Example_Quorum_Template
       │       ├───qstemplate.yaml
       │   
       ├───cmeasyinstall
       ├───sglx_update_image.bash   
       ├───Readme-SG-heat-templates.txt
       
Importance of each of the file and the required configuration parameters are 
explained in section 7 and 8 of this document.
      
#### 3. Software and Hardware Requirements
Serviceguard for Linux is supported on a wide range of hardware and several 
operating systems like Red Hat & SuSE Enterprise Linux. For a complete list of 
supported hardware & software, refer to Serviceguard for Linux Certification 
Matrix available at [Serviceguard-for-Linux-docs]

#### 4. Instructions to access cloud environment
As a HPE Helion OpenStack cloud end user, resources can be provisioned within the 
limits set by administrator. The examples in this document show how to accomplish 
several tasks by using the OpenStack dashboard and also command-line clients. 

The dashboard, also known as horizon, is a Web-based graphical user interface. 
The command-line clients lets you run simple commands to create and manage 
resources in a cloud and automate tasks.

Refer to the link [HPE-Helion-docs] for more information on HPE Helion OpenStack 

#### 5. Instructions to create and upload Operation System image
Serviceguard for Linux is supported on Red Hat & SuSE Enterprise Linux. The 
availability of these operating systems as part of the glance image repository
is a pre-requisite to instantiate and deploy clusters. Ensure that these images 
contain certain software pre-requisites as listed below.

Software that should be part of the Operating Systems Image:

- Bundle the image with python-openstack packages listed below:  
    * python-keystoneclient
    * python-novaclient
    * python-swiftclient
    * python-neutronclient
    * python-heatclient
      
- Serviceguard for Linux depends on several software provided by the 
  operating system vendor, ensure that all respective prerequisite software 
  are bundled with the image. For a complete list of prerequisites refer to 
  the section "Software Prerequisites for Serviceguard for Linux" in the 
  document "HPE Serviceguard for Linux Enterprise Edition Release Notes"
  available at [Serviceguard-for-Linux-docs]

- Post creating the image, ensure that the image is uploaded to glance image 
  repository. Refer to [HPE-Helion-docs] for more information on how to create and upload image to    glance repository in HPE Helion OpenStack. 
      
#### 6. Instructions to upload Serviceguard for Linux Image to glance repository
Serviceguard for Linux Image has to be uploaded to the glance image repository, 
that is required by the heat templates to automate the deployment of 
Serviceguard clusters.

Follow the instructions provided below to download Serviceguard for Linux image:

* Download Serviceguard for Linux from [Serviceguard-for-Linux-download]. Click on "download" and     follow the on screen instructions. 

* Select the product named "A.12.00.30 Enterprise Edition for Red Hat 
  Enterprise Linux 7". 
	   
* Upon Successful completion of download the following file will be present. 
  "A.12.00.30_Enterprise_Edition_for_Red_Hat_Enterprise_Linux_7_BB097-11002.iso"
     
* Copy the downloaded file to the directory on the system where the 
  Serviceguard Heat Templates git repository is cloned. 

      NOTE: All the deployed cloud services should be accessible from this system.
	   
* Change to directory on the system where the Serviceguard Heat Templates git repository is cloned. 
   Run the command sglx_update_image.bash which is present in the cloned 
   directory by providing the downloaded file as the argument. 
	   
    ```sh
    Ex: ./sglx_update_image.bash "PATH_TO_DOWNLOADED_ISO"
    ```
        
    ```sh
    # cd /root/sglx/
    #./sglx_update_image.bash /root/sglx/A.12.00.30_Enterprise_Edition_for_Red_Hat_Enterprise_Linux_7_BB097-11002.iso
    Successfully created the iso file /root/sglx/sglx.iso.
    #
   Here /root/sglx is the location where the the Serviceguard Heat Templates git repository is cloned.
    ```

* This would create a new Serviceguard for Linux ISO file by named sglx.iso
   in the same directory where the Serviceguard Heat Templates git repository is cloned. 
	```sh   
    Ex: /root/sglx/sglx.iso
    ```
    
  Serviceguard for Linux image can be uploaded to glance repository in one of the 
  following two options listed below:
	
  * Option 1: Command Line Interface  
	[OR]
  * Option 2: Horizon Dashboard. 

##### Option 1: Command Line Interface
----------------------------
Follow the instructions provided below to upload the Serviceguard for Linux image 
from command line to glance image repository:

- source required proxy to the command line.

- source required cloud credentials that will allow you to access cloud 
  services from the command line.   
   
- Run the following command:
    ```sh
    glance image-create –-name SGLX –-visibility public 
    –-container-format bare –-disk-format iso --file /root/sglx/sglx.iso
    ```

    In this command, SGLX is the name of the ISO image after it 
    is loaded to the glance repository and sglx.iso is the name of
    the source ISO image.
	   
- Verify that the image is uploaded to glance by running the command 
  “glance image-list” and ensure that you can see the new image SGLX.
```sh
For Ex: 	   
+--------------------------------------+---------------------------------+
| ID                                   | Name                            |
+--------------------------------------+---------------------------------+
| 42685640-3dd1-4f39-8e5a-6f28a4508cfa | cirros-0.3.4-x86_64-uec         |
| 4c6c17ab-db7b-472e-960a-cba22a623b4b | Rhel6                           |
| 15eb9737-bfd2-4f06-8166-724d8ee8c759 | SGLX                            |
+--------------------------------------+---------------------------------+
```
	    NOTE: The Image ID can be different.

##### Option 2: Horizon Dashboard
----------------------------
Follow the instructions provided below to upload the Serviceguard for Linux image 
from Horizon Dashboard to glance image repository:

- Launch the Horizon Dashboard.	  

- On the left side of the page, list of services will be displayed, click 
  on "System" and then select "Images".
	   
- Select the option : "create image".
	
- Specify the Name of the image as "SGLX"
	
- Select Image Source as Image File and Browse to the location of the 
  file where the Serviceguard for Linux Image resides i.e /root/sglx/sglx.iso. 
	         
- Under the "Format" section, specify the format as ISO
	
- Select the check box "Public" or "Protected" appropriately.
	
- Finally click on "Create image".
   
This will create SGLX image as one of the image in the glance image repository.

#### 7. Deploy Serviceguard for Linux Quorum Server
The Serviceguard Quorum Server provides arbitration services for Serviceguard 
clusters when a cluster partition is discovered: must equal-sized groups of nodes 
become separated from each other, the Quorum Server allows one group to achieve 
quorum and form the cluster, while the other group is denied quorum and cannot 
start a cluster.

This section can be skipped if a Serviceguard for Linux Quorum Server already 
exists and is reachable over network from the cluster node instances that are 
being spawned from the cloud environment.

Heat Stack template that can be generated for Serviceguard for Linux Quorum Server
provided below is for Red Hat Enterprise Linux 6 Operating System (RHEL6) only. 
Ensure that RHEL6 is available as part of glance image repository. 

Alternatively one can setup Quorum Server for the desired operating system by 
following the instructions mentioned in the document 
"HPE Serviceguard Quorum Server for Linux Version A.12.00.30 Release Notes" 
available at [Serviceguard-for-Linux-docs].

##### Description of various files
Traverse to the directory on the system where the Serviceguard Heat Templates git repository is cloned. There will be a directory by named "sg_quorum". Traverse to the directory 
"sg_quorum".

The directory "sg_quorum" contains the following files:
```sh
quorumconfig: This file contains the configurable parameters that will be 
            consumed by the script quorum.bash to generate the Quorum Server Heat 
            Stack YAML file.
	  
quorum.bash: This script contains the logic to generate the Quorum Server 
            Heat Stack YAML file.
	  
Example_Quorum_Template: This directory contains an example Quorum Server 
            Heat Stack YAML file.
```	  
Follow the instructions provided below to configure, generate and instantiate 
a Serviceguard for Linux Quorum Server:

- All the deployed cloud services should be accessible from this system.

- Open and edit the file "quorumconfig" present in the directory "sg_quorum" 
  by following the detailed instructions provided in the file "quorumconfig".
   
- Execute the bash script "quorum.bash" present in the directory "sg_quorum". 
  Post successful run of "quorum.bash", a new Quorum Server Heat Stack 
  Template file will be created. The name of the file will be the name of 
  the stack specified in the "quorumconfig" with an extension of YAML.
    
        For Ex: bash quorum.bash
        If STACK_NAME=sgqs, then sgqs.yaml will be the newly generated Quorum
        Server Heat Stack Template file.
   
- The stack can be launched either via command line interface or from the 
  Horizon Dashboard.

##### Option 1: Launch the Stack from Command Line Interface
------------------------------------------------------
        
- source the required proxy to the command line.
	
- source the required cloud credentials that will allow you to access cloud 
           services from the command line.
	  
- Run the following command: 

        heat stack-create sgqs -f sgqs.yaml
        Here "sgqs" is the name of the stack & "sgqs.yaml" is the path to 
        the heat template file that was generated.

##### Option 2: Launch the Stack from Horizon Dashboard
------------------------------------------------------

- Launch the Horizon Dashboard.	  

- On the left side of the page, click on project.
	   
- Click on Orchestration and then click on stacks.

- Click on Launch Stack and select the Template Source as file. 
		
- Browse to the directory containing the required Heat template 
  file and select it.
		   
- Under Environment Source, Select the default configuration 
  environment file.
		   
- Click on next

- Provide the name of the stack and click on launch.
		
This will create the new Quorum Server instance based on the Heat Template.

#### 8. Deploy Serviceguard clusters using Serviceguard Heat Templates
This section talks about how to instantiate Serviceguard for Linux Cluster via 
the Serviceguard Heat Templates.

##### Description of various files
Traverse to the directory on the system where the Serviceguard Heat Templates git repository is cloned. There will be a directory by named "sg_cluster". Traverse to the directory 
"sg_cluster".

The directory "sg_cluster" contains the following files:
```sh
   a. clusterconfig: This file contains the configurable parameters that will be 
            consumed by the script sgcluster.bash to generate the Serviceguard cluster 
	        Heat Stack YAML file.
	  
   b. sgcluster.bash: This script contains the logic to generate the Serviceguard 
            Clusters Heat Stack YAML file, based on the parameters specified. The  
	        parameters are explained in Section 8.3 below.
	  
   c. Example_SG_Cluster_Template: This directory contains example Serviceguard
            Cluster Heat Stack YAML files.
```

Follow the instructions provided below to configure, generate and instantiate a 
Serviceguard for Linux Cluster:

- All the deployed cloud services should be accessible from this system.

- Open and edit the file "clusterconfig" present in the directory "sg_cluster" 
  by following the detailed instructions provided in the file "clusterconfig".

- Issue the command on the command line:
    ```sh
    bash sgcluster.bash -o <name_of_operating_system> -n <number_of_nodes> -s <name_of_stack>
    ```
    Post successful run of "sgcluster.bash" a new Serviceguard Cluster
    Heat Stack Template file will be created. The name of the file 
    will be the name of the stack specified as input parameter with 
    an extension of YAML.
				
    **Parameters to be passed to the Script sgcluster.bash**

		-o name_of_operating_system: 
			Specify the Operating System Image Name, the name of the image 
			should match with the name as displayed in the list of images in 
			glance image repository.

		-n number_of_nodes: 
			Number of Nodes in the cluster that is required.
	  			
		-s stack_name: 
			The Name of the stack that will be created. Instances created will 
			have a suffix of stack name followed by the number.
									
    For example:

    ```sh
    # bash sgcluster.bash -o Rhel6 -n 2 -s sgeasy
	This will creates a Serviceguard Cluster Heat Template file sgeasy.YAML.
			
	Here sgcluster.bash is the bash script that is present in the directory  
	"sg_cluster". 

	Rhel6 is the name of the operating system that is used in launching 
	instances of cluster. 

	2 is the Number of nodes in the cluster (Considering the user has 
	chosen 2 as the number of nodes, Instances of the cluster will have 
	the name sgeasy1 and sgeasy2). In general, instance names will be 
	stackname followed by number 1 to n. Where n corresponds to the 
	number of nodes chosen by the user
		 
	sgeasy is the name of the stack.
    ```

- The stack can be launched either via command line interface or from the 
  Horizon Dashboard.

##### Option 1: Launch the Stack from Command Line Interface
------------------------------------------------------
- source required proxy to the command line.
	
- source required cloud credentials that will allow you to access cloud 
  services from the command line.
	  
- Run the following command: 

		   heat stack-create sgeasy -f sgeasy.yaml
		   Here "sgeasy" is the name of the stack & "sgeasy.yaml" is the path to 
		   the heat template file that was generated.

##### Option 2: Launch the Stack from Horizon Dashboard
------------------------------------------------------
- Launch the Horizon Dashboard.	

- On the left side of the page, click on project.
	   
- Click on Orchestration and then click on stacks.

- Click on Launch Stack and select the Template Source as file. 
		
- Browse to the directory containing the required Heat template 
  file and select it.
		   
- Under Environment Source, Select the default configuration 
  environment file.
		   
- Click on next

- Provide the name of the stack and click on launch.
		
This will create the new Serviceguard Cluster based on the Heat Template.

### References used in creating readme document
1. The latest documentation for Serviceguard Linux is available in
at [Serviceguard-for-Linux-docs]

    * HP Serviceguard for Linux Base Version 12.00.30
      Release Notes
    * HP Serviceguard for Linux Advanced Version 12.00.30
      Release Notes
    * HP Serviceguard for Linux Enterprise Version 12.00.30
      Release Notes
    * Managing HP Serviceguard A.12.00.30 for Linux

2. Refer to the link provided below for more information on HPE Helion OpenStack 
[HPE-Helion-docs]

3. Refer to the link provided below for OpenStack Documentation
[OpenStack-docs]

### Copyrights

Linux® is the registered trademark of Linus Torvalds in the U.S. and other countries.

Red Hat® Enterprise Linux® Red Hat is a trademark of Red Hat, Inc. in the U.S. 
and other countries. Linux is a registered trademark of Linus Torvalds.

SUSE® is a registered trademark of SUSE.

The OpenStack® Word Mark and OpenStack Logo are either registered 
trademarks/service marks or trademarks/service marks of the OpenStack Foundation 
in the United States and other countries and are used with the OpenStack 
Foundation's permission. We are not affiliated with, endorsed or sponsored 
by the OpenStack Foundation or the OpenStack community.

[//]: # (These are reference links used)
[Serviceguard-for-Linux-docs]: <http://www.hpe.com/info/linux-serviceguard-docs>
[HPE-Helion-docs]: <https://docs.hpcloud.com/#home.html>
[Serviceguard-for-Linux-download]: <http://hpe.com/servers/sglx>
[OpenStack-docs]: <http://docs.openstack.org/>

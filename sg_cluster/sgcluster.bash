#!/bin/bash
#(C) Copyright 2016 Hewlett Packard Enterprise Development Company, L.P.
#########################################################################################
# This Script uses the configuration as specified in the clusterconfig file to 
# generate Heat Template file for Serviceguard cluster.
# Specify the following three Parameters as command line arguments to this script.
# 
# -o name_of_operating_system : 
#             Specify the Operating System Image Name for the Virtual Machine
#             that is spawned. The name of the image should match with the name
#             as displayed in the list of images in glance.
# -n number_of_nodes          : 
#             Specify the Number of nodes in the cluster.
# -s name_of_stack            : 
#             Specify the Name of the Stack.
#########################################################################################
source clusterconfig

SG_IMAGE_NAME=""
NUM_OF_NODES=""
STACK_NAME=""

print_usage ()
{
    echo "Usage: sgcluster -o name_of_operating_system -n number_of_nodes -s name_of_stack"
    echo "     -o name_of_operating_system : Indicate the name of the operating system."
    echo "     -n number_of_nodes          : Specify the Number of nodes in the cluster."
    echo "     -s name_of_stack            : Specify the Name of the Stack."
    echo "                                   Instance name will be prefixed with name of the stack."
    exit 1
}

if  [[ $# -ne 6 ]]; then
    print_usage
fi

while [ $# -gt 0 ]; do
    case "$1" in
        -o) if [ $# -gt 1 ]; then
                SG_IMAGE_NAME="$2"
                shift 2
            else
                print_usage
            fi ;;
        -n)  if [ $# -gt 1 ]; then
                    NUM_OF_NODES="$2"
                    shift 2
                else
                    print_usage
                fi ;;
        -s)  if [ $# -gt 1 ]; then
                    STACK_NAME="$2"
                    shift 2
                else
                    print_usage
                fi ;;
        *)   echo "Invalid Argument $1"
             print_usage
    esac
done				

#########################################################################################
# This script generates a Serviceguard for Linux Quorum Server Heat Template.

echo -e  "heat_template_version: 2013-05-23\n" >> $STACK_NAME.yaml

echo -e "description: Serviceguard on Linux Cluster Template\n" >> $STACK_NAME.yaml

echo "parameters:" >> $STACK_NAME.yaml
echo "  image:" >> $STACK_NAME.yaml
echo "    type: string" >> $STACK_NAME.yaml
echo "    label: Image name or ID" >> $STACK_NAME.yaml
echo "    description: Image to be used for Serviceguard Node instance" >> $STACK_NAME.yaml
echo "    default: $SG_IMAGE_NAME" >> $STACK_NAME.yaml

echo "  key:" >> $STACK_NAME.yaml
echo "    type: string" >> $STACK_NAME.yaml
echo "    description: Name of keypair to assign to servers" >> $STACK_NAME.yaml
echo "    default: $SG_KEY_NAME" >> $STACK_NAME.yaml

echo "  flavor:" >> $STACK_NAME.yaml
echo "    type: string" >> $STACK_NAME.yaml
echo "    label: Flavor" >> $STACK_NAME.yaml
echo "    description: Type of instance (flavor) to be used" >> $STACK_NAME.yaml
echo "    default: $SG_FLAVOR_NAME" >> $STACK_NAME.yaml

echo "  private_network:" >> $STACK_NAME.yaml
echo "    type: string" >> $STACK_NAME.yaml
echo "    label: Private network name or ID" >> $STACK_NAME.yaml
echo "    description: Network to attach instance to." >> $STACK_NAME.yaml
echo -e  "    default: $SG_NETWORK_ID\n" >> $STACK_NAME.yaml

#########################################################################################
echo "resources:" >> $STACK_NAME.yaml
for ((i=1; i <= NUM_OF_NODES-1 ; i++))
do
    echo "  cloud$i:" >> $STACK_NAME.yaml
    echo "    type: OS::Nova::Server" >> $STACK_NAME.yaml
    echo "    properties:" >> $STACK_NAME.yaml
    echo "      name: $STACK_NAME$i" >> $STACK_NAME.yaml
    echo "      image: { get_param: image }" >> $STACK_NAME.yaml
    echo "      flavor: { get_param: flavor }" >> $STACK_NAME.yaml
    echo "      key_name: { get_param: key }" >> $STACK_NAME.yaml
    echo "      networks:" >> $STACK_NAME.yaml
    echo "        - network: { get_param: private_network }" >> $STACK_NAME.yaml
    echo "      user_data: |" >> $STACK_NAME.yaml
    echo "          #!/bin/sh" >> $STACK_NAME.yaml
    echo "          cd /root" >> $STACK_NAME.yaml
    echo "          glance --os-username $AUTH_USERNAME --os-password $AUTH_PASSWORD --os-tenant-id $AUTH_TOKEN --os-auth-url $AUTH_URL image-download --file ./$SGLX_PRODUCT_NAME $SGLX_PRODUCT_ID" >> $STACK_NAME.yaml
    echo "          mkdir  serviceguard" >> $STACK_NAME.yaml
    echo "          sleep 2" >> $STACK_NAME.yaml
    echo "          chmod 700 /root/.ssh" >> $STACK_NAME.yaml
    echo "          sleep 2" >> $STACK_NAME.yaml
    echo "          if [[ \$UID -ne 0 ]]; then" >> $STACK_NAME.yaml
    echo "             echo \"You must be a root user\" 2>&1" >> $STACK_NAME.yaml
    echo "             exit 1" >> $STACK_NAME.yaml
    echo "          else" >> $STACK_NAME.yaml
    echo "             mount -o loop $SGLX_PRODUCT_NAME /root/serviceguard" >> $STACK_NAME.yaml
    echo "             sleep 2" >> $STACK_NAME.yaml
    echo "             /root/serviceguard/cmeasyinstall -n \`hostname\` -j /opt/jetty -a -l -d /root/serviceguard" >> 	$STACK_NAME.yaml
    echo "             sleep 3" >> $STACK_NAME.yaml
    echo "          fi" >> $STACK_NAME.yaml
    echo "          sleep 6" >> $STACK_NAME.yaml
    echo   '          echo "`ifconfig | grep 'inet' | grep -v '127.0.0.1' | awk '\''{print $2}'\'' | sed 's/addr://'``hostname`.openstacklocal `hostname -s`" >> /etc/hosts ' >> $STACK_NAME.yaml
    echo "          service network restart" >> $STACK_NAME.yaml
    echo "          sleep 30" >> $STACK_NAME.yaml
    echo -e  "      user_data_format: RAW\n" >> $STACK_NAME.yaml
done
#########################################################################################

if [[ "i" -eq "NUM_OF_NODES" ]]
then
    echo "  cloud$i:" >> $STACK_NAME.yaml
    echo "    type: OS::Nova::Server" >> $STACK_NAME.yaml
    IFS='%'
    i=1
    while((i<NUM_OF_NODES))
    do
    arg=$arg"cloud$i "
    if((i!= (NUM_OF_NODES-1)))
    then
    arg=$arg","
    fi
    i=$((i+1))
    done
    cmd="depends_on: [ "
    cmd2="]"
    arg=$cmd$cmd1$arg$cmd2
    echo "    $arg" >> $STACK_NAME.yaml
    echo "    properties:" >> $STACK_NAME.yaml
    echo "      name: $STACK_NAME$NUM_OF_NODES" >> $STACK_NAME.yaml
    echo "      image: { get_param: image }" >> $STACK_NAME.yaml
    echo "      flavor: { get_param: flavor }" >> $STACK_NAME.yaml
    echo "      key_name: { get_param: key }" >> $STACK_NAME.yaml
    echo "      networks:" >> $STACK_NAME.yaml
    echo "        - network: { get_param: private_network }" >> $STACK_NAME.yaml
    echo "      user_data: " >> $STACK_NAME.yaml
    echo "        str_replace: " >> $STACK_NAME.yaml
    echo "           template: | " >> $STACK_NAME.yaml
    echo "              #!/bin/sh" >> $STACK_NAME.yaml
    echo "              cd /root" >> $STACK_NAME.yaml
    echo "              glance --os-username $AUTH_USERNAME --os-password $AUTH_PASSWORD --os-tenant-id $AUTH_TOKEN --os-auth-url $AUTH_URL image-download --file ./$SGLX_PRODUCT_NAME $SGLX_PRODUCT_ID" >> $STACK_NAME.yaml
    echo "              mkdir  serviceguard" >> $STACK_NAME.yaml
    echo "              sleep 2" >> $STACK_NAME.yaml
    echo "              chmod 700 /root/.ssh" >> $STACK_NAME.yaml
    echo "              sleep 2" >> $STACK_NAME.yaml
    echo "              if [[ \$UID -ne 0 ]]; then" >> $STACK_NAME.yaml
    echo "                 echo \"You must be a root user\" 2>&1" >> $STACK_NAME.yaml
    echo "                 exit 1" >> $STACK_NAME.yaml
    echo "              else" >> $STACK_NAME.yaml
    echo "                 mount -o loop $SGLX_PRODUCT_NAME /root/serviceguard" >> $STACK_NAME.yaml
    echo "                 sleep 2" >> $STACK_NAME.yaml
    echo "                 /root/serviceguard/cmeasyinstall -n \`hostname\` -j /opt/jetty -a -l -d /root/serviceguard" >> $STACK_NAME.yaml
    echo "                 sleep 3" >> $STACK_NAME.yaml
    echo "              fi" >> $STACK_NAME.yaml
    echo "              sleep 6" >> $STACK_NAME.yaml
    echo   '              echo "`ifconfig | grep 'inet' | grep -v '127.0.0.1' | awk '\''{print $2}'\'' | sed 's/addr://'` `hostname`.openstacklocal `hostname -s`" >> /etc/hosts ' >> $STACK_NAME.yaml
    echo '              echo '$SG_QS_IP_ADDRESS $SG_QS_SERVER_FQDN $SG_QS_SERVER' >> /etc/hosts' >> $STACK_NAME.yaml
	
    for ((i=1; i <= NUM_OF_NODES-1 ; i++))
    do
     echo "              echo 'instance$i-ip_address $STACK_NAME$i.openstacklocal $STACK_NAME$i' >> /etc/hosts" >> $STACK_NAME.yaml
    done
	
    echo "              service network restart" >> $STACK_NAME.yaml
    echo "              sleep 20" >> $STACK_NAME.yaml
	
    for ((i=1; i <= NUM_OF_NODES-1 ; i++))
    do
     echo "              curl -k -T /etc/hosts -u root:$INSTANCE_PASSWORD scp://root@instance$i-ip_address/etc/hosts" >> $STACK_NAME.yaml
     echo "              sleep 40" >> $STACK_NAME.yaml
    done
	
    echo "              ssh-keygen -f /root/.ssh/id_rsa -t rsa -N ''" >> $STACK_NAME.yaml
    echo "              sleep 40" >> $STACK_NAME.yaml
	
    for ((i=1; i <= NUM_OF_NODES-1 ; i++))
    do
     echo "              curl -k -T /root/.ssh/id_rsa.pub -u root:$INSTANCE_PASSWORD scp://root@instance$i-ip_address/root/.ssh/authorized_keys2" >> $STACK_NAME.yaml
     echo "              sleep 40" >> $STACK_NAME.yaml
    done

    IFS='%'
    arg=" "
    i=1
    while((i<NUM_OF_NODES))
    do
    arg=$arg"-n $STACK_NAME$i "
    i=$((i+1))
    done
    cmd="sh -lic 'cmdeploycl -n \`hostname\` "
    cmd1="-q $SG_QS_SERVER"
	
    echo "              $cmd$arg$cmd1'" >> $STACK_NAME.yaml
    echo "              sleep 70" >> $STACK_NAME.yaml
    echo "           params:" >> $STACK_NAME.yaml
	
    for ((i=1; i <= NUM_OF_NODES-1 ; i++))
    do
     echo "             instance$i-ip_address: { get_attr: [cloud$i,networks,private,1] }" >> $STACK_NAME.yaml
    done
	
fi

#########################################################################################
#Provide the Outputs in the Output part of template, helps for the user to access.
#For example, the IP address by which the instance defined in the example above 
#can be accessed should be provided to users. The definition for providing the 
#IP address of the compute instance as an output is shown in the following snippet:

echo "outputs:" >> $STACK_NAME.yaml
for ((i=1; i <= $NUM_OF_NODES ; i++))
do
 echo "  instance_name$i:" >> $STACK_NAME.yaml
 echo "    description: Name of the instance" >> $STACK_NAME.yaml
 echo "    value: { get_attr: [cloud$i, name] }" >> $STACK_NAME.yaml
 echo "  instance_ip$i:" >> $STACK_NAME.yaml
 echo "    description: IP address of the instance" >> $STACK_NAME.yaml
 echo "    value: { get_attr: [cloud$i,networks,private,1] }" >> $STACK_NAME.yaml
done

#########################################################################################

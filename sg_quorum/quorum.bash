#!/bin/bash
#(C) Copyright 2016 Hewlett Packard Enterprise Development Company, L.P.

# This Script uses the configuration as specified in the quorumconfig file to 
# generate Heat Template file for Quorum Server.
# The Quorum Server Heat Template presently works only for Red Hat 6 Enterprise
# Linux based Quorum Servers.

source quorumconfig

#########################################################################################
# This script generates a Serviceguard for Linux Quorum Server Heat Template.

echo -e  "heat_template_version: 2013-05-23\n" >> $STACK_NAME.yaml

echo -e "description: Serviceguard on Linux Quorum Server Template\n" >> $STACK_NAME.yaml

echo "parameters:" >> $STACK_NAME.yaml
echo "  image:" >> $STACK_NAME.yaml
echo "    type: string" >> $STACK_NAME.yaml
echo "    label: Image name or ID" >> $STACK_NAME.yaml
echo "    description: Image to be used for Quorum Server instance" >> $STACK_NAME.yaml
echo "    default: $QS_IMAGE_NAME" >> $STACK_NAME.yaml

echo "  key:" >> $STACK_NAME.yaml
echo "    type: string" >> $STACK_NAME.yaml
echo "    description: Name of keypair to assign to servers" >> $STACK_NAME.yaml
echo "    default: $QS_KEY_PAIR_NAME" >> $STACK_NAME.yaml

echo "  flavor:" >> $STACK_NAME.yaml
echo "    type: string" >> $STACK_NAME.yaml
echo "    label: Flavor" >> $STACK_NAME.yaml
echo "    description: Type of instance (flavor) to be used" >> $STACK_NAME.yaml
echo "    default: $QS_FLAVOR_NAME" >> $STACK_NAME.yaml

echo "  private_network:" >> $STACK_NAME.yaml
echo "    type: string" >> $STACK_NAME.yaml
echo "    label: Private network name or ID" >> $STACK_NAME.yaml
echo "    description: Network to attach instance to." >> $STACK_NAME.yaml
echo -e  "    default: $QS_NETWORK_ID\n" >> $STACK_NAME.yaml

#########################################################################################
echo "resources:" >> $STACK_NAME.yaml
    echo "  cloud1:" >> $STACK_NAME.yaml
    echo "    type: OS::Nova::Server" >> $STACK_NAME.yaml
    echo "    properties:" >> $STACK_NAME.yaml
    echo "      name: $QUORUMSERVER_NAME" >> $STACK_NAME.yaml
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
    echo "          fi" >> $STACK_NAME.yaml
    echo "          sleep 6" >> $STACK_NAME.yaml
    echo "          rpm -ivh /root/serviceguard/RedHat/RedHat6/QuorumServer/x86_64/serviceguard-qs-A.12.00.00-0.rhel6.x86_64.rpm" >> $STACK_NAME.yaml
    echo "          echo \" + + \" >> /usr/local/qs/conf/qs_authfile" >> $STACK_NAME.yaml
    echo "          iptables --flush" >> $STACK_NAME.yaml
    echo "          iptables -F" >> $STACK_NAME.yaml
    echo "          iptables -A INPUT -i eth0 -p tcp --dport 1238 -m state --state NEW,ESTABLISHED -j ACCEPT" >> $STACK_NAME.yaml
    echo "          iptables -A OUTPUT -o eth0 -p tcp --sport 1238 -m state --state ESTABLISHED -j ACCEPT" >> $STACK_NAME.yaml
    echo "          iptables -A INPUT -i eth0 -p udp --dport 1238 -m state --state NEW,ESTABLISHED -j ACCEPT" >> $STACK_NAME.yaml
    echo "          iptables -A OUTPUT -o eth0 -p udp --sport 1238 -m state --state ESTABLISHED -j ACCEPT" >> $STACK_NAME.yaml
    echo "          sleep 4" >> $STACK_NAME.yaml
    echo "          /usr/local/qs/bin/qs" >> $STACK_NAME.yaml
    echo   '          echo "`ifconfig | grep 'inet' | grep -v '127.0.0.1' | awk '\''{print $2}'\'' | sed 's/addr://'` `hostname`.openstacklocal `hostname -s`" >> /etc/hosts ' >> $STACK_NAME.yaml
    echo "          service network restart" >> $STACK_NAME.yaml
    echo "          sleep 30" >> $STACK_NAME.yaml
	echo "          /usr/local/qs/bin/qs" >> $STACK_NAME.yaml
    echo "          sleep 2" >> $STACK_NAME.yaml
    echo -e  "      user_data_format: RAW\n" >> $STACK_NAME.yaml

#########################################################################################
#Provide the Outputs in the Output part of template, helps for the user to access.
#For example, the IP address by which the instance defined in the example above 
#can be accessed should be provided to users. The definition for providing the 
#IP address of the compute instance as an output is shown in the following snippet:

echo "outputs:" >> $STACK_NAME.yaml
 echo "  instance_name1:" >> $STACK_NAME.yaml
 echo "    description: Name of the Quorum Server instance" >> $STACK_NAME.yaml
 echo "    value: { get_attr: [cloud1, name] }" >> $STACK_NAME.yaml
 echo "  instance_ip1:" >> $STACK_NAME.yaml
 echo "    description: IP address of the instance" >> $STACK_NAME.yaml
 echo "    value: { get_attr: [cloud1,networks,private,1] }" >> $STACK_NAME.yaml

########################################################################################
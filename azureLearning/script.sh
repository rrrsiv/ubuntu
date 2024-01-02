#!/bin/bash

RG=kavi-RG
echo ${RG}

echo "creating resourse group in eastus"
az group create --location eastus -n ${RG}

echo "creating vnet "
az network vnet create -g ${RG} -n ${RG}-vNET1 --address-prefix 10.10.0.0/16 --subnet-name ${RG}-subnet1 --subnet-prefix 10.10.10.0/24 -l eastus

echo "creating subnets in vNET"
az network vnet subnet create -g ${RG} --vnet-name ${RG}-vNET1 --name ${RG}-subnet1 --address-prefixes "10.10.10.0/24" 
az network vnet subnet create -g ${RG} --vnet-name ${RG}-vNET1 --name ${RG}-subnet2  --address-prefixes "10.10.20.0/24"
az network vnet subnet create -g ${RG} --vnet-name ${RG}-vNET1 --name ${RG}-subnet3 --address-prefixes "10.10.30.0/24"
az network vnet subnet create -g ${RG} --vnet-name ${RG}-vNET1 --name ${RG}-AppGW-subnet --address-prefixes "10.10.40.0/24"

echo "creating virtual machines"
az vm create --resource-group ${RG} --name testvm1 --image Ubuntu2204 --vnet-name ${RG}-vNET1 --subnet ${RG}-subnet1 --admin-username siva_admin --admin-password "Kavisiva@7453" --size  Standard_B1s --nsg "" --custom-data /home/siva/clouddrive/init.txt
az vm create --resource-group ${RG} --name testvm2 --image Ubuntu2204 --vnet-name ${RG}-vNET1 --subnet ${RG}-subnet2 --admin-username siva_admin --admin-password "Kavisiva@7453" --size Standard_B1s --nsg "" --custom-data /home/siva/clouddrive/init.txt
az vm create --resource-group ${RG} --name testvm3 --image Ubuntu2204 --vnet-name ${RG}-vNET1 --subnet ${RG}-subnet3 --admin-username siva_admin --admin-password "Kavisiva@7453" --size Standard_B1s --custom-data /home/siva/clouddrive/init.txt
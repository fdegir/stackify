#!/bin/bash

# create VMs
function create_vm {
    NODE_CONFIG=${1}

    # source configuration for the node
    source ${NODE_CONFIG}

    # first remove the VM if it exists
    vboxmanage showinfo ${STACKIFY_NAME} 2> /dev/null || delete_vm ${STACKIFY_NAME}

    echo "-> Creating ${STACKIFY_NAME}"

    # create the VM
    vboxmanage createvm --name ${STACKIFY_NAME}  --ostype ${STACKIFY_OSTYPE} --basefolder ${STACKIFY_VMDIR} --register > /dev/null
    
    # configure memory, acpi, and boot device
    vboxmanage modifyvm ${STACKIFY_NAME} --memory ${STACKIFY_MEMORY} --acpi on --boot1 dvd

    # configure initial networking
    # create bridged adapter so we can reach to VM later on
    vboxmanage modifyvm ${STACKIFY_NAME} --nic1 bridged
    vboxmanage modifyvm ${STACKIFY_NAME} --bridgeadapter1 "en0: Wi-Fi (AirPort)"

    # configure the storage
    vboxmanage storagectl ${STACKIFY_NAME} --name IDE --add ide --controller PIIX4 --portcount 2 --bootable on
    vboxmanage storageattach ${STACKIFY_NAME} --storagectl IDE --port 1 --device 0 --medium /Users/fdegir/stackify/osiso/autoinstall.iso --type dvddrive
    vboxmanage storagectl ${STACKIFY_NAME} --name SATA --add sata --controller IntelAhci --portcount 1 --bootable on
    vboxmanage createhd --filename ${STACKIFY_VMDIR}/${STACKIFY_NAME}/${STACKIFY_NAME}.vdi --size ${STACKIFY_SIZE} --format VDI > ${STACKIFY_LOGFILE} 2>&1
    vboxmanage storageattach ${STACKIFY_NAME} --storagectl SATA --port 0 --device 0 --medium ${STACKIFY_VMDIR}/${STACKIFY_NAME}/${STACKIFY_NAME}.vdi --type hdd

    # get the UUID and inform user
    UUID=$(vboxmanage showvminfo ${STACKIFY_NAME} --machinereadable | grep "^UUID" | cut -d"=" -f2)

    echo "-> Created VM \"${STACKIFY_NAME}\" with UUID ${UUID}"

}

function start_vms {
    STACKIFY_VMS=$1

    for VM in ${STACKIFY_VMS}; do
        echo "-> Starting VM \"${VM}\""
        vboxmanage startvm ${VM} --type headless > ${STACKIFY_LOGFILE} 2>&1
        if [ $? != 0 ]; then
            echo "-> Failed starting VM \"${STACKIFY_NAME}\""
        fi
    done
    echo "-> All VMs are started. Waiting for installations to finish."

    i=0;
    for j in {1..60}; do
        for VM in ${STACKIFY_VMS}; do
            vboxmanage guestproperty get ${VM} "/VirtualBox/GuestInfo/Net/0/V4/IP" | grep -i "no value" > /dev/null
            if [ "$?" != "0" ]; then
                VM_IP=$(vboxmanage guestproperty get ${VM} "/VirtualBox/GuestInfo/Net/0/V4/IP" | cut -d" " -f2)
                sshpass -p stackify ssh -o StrictHostKeyChecking=no stackify@${VM_IP} "ls /home/stackify/stackify.done > /dev/null" > /dev/null 2>&1
                if [ "$?" == "0" ]; then
                    echo -e "\n-> VM \"${VM}\" installation is completed! IP is ${VM_IP}"
                    sshpass -p stackify ssh -o StrictHostKeyChecking=no stackify@${VM_IP} "/bin/rm /home/stackify/stackify.done" > /dev/null 2>&1
                    i=$((i+1))
                    STACKIFY_VMS=$(echo "${STACKIFY_VMS}" | sed "s/${VM}//g")
                fi
            fi
        done

        echo -n "."

        if [ $i == 3 ]; then
            break
        fi
        sleep 15
    done

    echo -e "\n-> Installation of nodes completed!"
}

function delete_vm {
    STACKIFY_NAME=$1

    echo "-> Deleting ${STACKIFY_NAME}"
    vboxmanage unregistervm ${STACKIFY_NAME}  --delete 2> /dev/null
}






# networking stuff left to configure
#    vboxmanage modifyvm controller_node --nic2 natnetwork
#    vboxmanage modifyvm controller_node --nat-network2 ManagementNetwork
#    vboxmanage modifyvm controller_node --nic3 natnetwork
#    vboxmanage modifyvm controller_node --nat-network3 TunnelNetwork
#

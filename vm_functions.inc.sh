#!/bin/bash

# create VMs
function create_vm {
    NODE_CONFIG=${1}

    # source configuration for the node
    source ${NODE_CONFIG}

    # first remove the VM if it exists
    VBoxManage showinfo ${STACKIFY_NAME} 2> /dev/null || delete_vm ${STACKIFY_NAME}

    echo "-> Creating ${STACKIFY_NAME}"

    # create the VM
    VBoxManage createvm --name ${STACKIFY_NAME}  --ostype ${STACKIFY_OSTYPE} --basefolder ${STACKIFY_VMDIR} --register > /dev/null
    
    # configure the VM
    VBoxManage modifyvm ${STACKIFY_NAME} --memory ${STACKIFY_MEMORY} --acpi on --boot1 dvd
    VBoxManage storagectl ${STACKIFY_NAME} --name IDE --add ide --controller PIIX4 --portcount 2 --bootable on
    #VBoxManage storageattach ${STACKIFY_NAME} --storagectl IDE --port 1 --device 0 --medium /Users/fdegir/Downloads/lubuntu-14.10-desktop-amd64.iso --type dvddrive
    VBoxManage storagectl ${STACKIFY_NAME} --name SATA --add sata --controller IntelAhci --portcount 1 --bootable on
    VBoxManage createhd --filename ${STACKIFY_VMDIR}/${STACKIFY_NAME}/${STACKIFY_NAME}.vdi --size ${STACKIFY_SIZE} --format VDI > ${STACKIFY_LOGFILE} 2>&1
    VBoxManage storageattach ${STACKIFY_NAME} --storagectl SATA --port 0 --device 0 --medium ${STACKIFY_VMDIR}/${STACKIFY_NAME}/${STACKIFY_NAME}.vdi --type hdd

    UUID=$(VBoxManage showvminfo ${STACKIFY_NAME} --machinereadable | grep "^UUID" | cut -d"=" -f2)
    echo "-> Created VM \"${STACKIFY_NAME}\" with UUID ${UUID}"
}

function delete_vm {
    STACKIFY_NAME=$1

    echo "-> Deleting ${STACKIFY_NAME}"
    VBoxManage unregistervm ${STACKIFY_NAME}  --delete 2> /dev/null
}

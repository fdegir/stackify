#!/bin/bash

# first, set some environment variables
export SCRIPT_PATH="$(dirname ${0})"
export STACKIFY_BASEDIR="${HOME}/stackify"
export STACKIFY_LOGDIR="${STACKIFY_BASEDIR}/logs"
export STACKIFY_LOGFILE="${STACKIFY_LOGDIR}/stackify.out"
export STACKIFY_ERRFILE="${STACKIFY_LOGDIR}/stackify.err"
export STACKIFY_VMDIR="${STACKIFY_BASEDIR}/vmstore"

# prepare directories
[[ -d ${STACKIFY_BASEDIR} ]] || mkdir -p ${STACKIFY_BASEDIR}
[[ -d ${STACKIFY_LOGDIR} ]] || mkdir -p ${STACKIFY_LOGDIR}
[[ -d ${STACKIFY_VMDIR} ]] || mkdir -p ${STACKIFY_VMDIR}

# redirect stdout and stderr to corresponding files
exec  > >(tee -a ${STACKIFY_LOGFILE})
exec 2> >(tee -a ${STACKIFY_ERRFILE} >&2)

# source include scripts
source "${SCRIPT_PATH}/vm_functions.inc.sh"

# check if user specified configuration file is in use
STACKIFY_VM_CONF_FILE=$1
if [ "${STACKIFY_VM_CONF_FILE}" != "" ] && [ -e "${STACKIFY_VM_CONF_FILE}" ]; then
    # get list of VMs from user specified configuration file
    echo "-> Using provided VM configuration file ${STACKIFY_VM_CONF_FILE}"
    source ${STACKIFY_VM_CONF_FILE}
else
    # get list of VMs from default configuration files
    echo "-> Using default VM configuration file ${SCRIPT_PATH}/vm.conf"
    source ${SCRIPT_PATH}/vm.conf
fi

for NODE_CONFIG in $(echo ${STACKIFY_NODE_CONF} | sed "s/,/ /g"); do
    echo "-> Found node configuration file ${SCRIPT_PATH}/${NODE_CONFIG}"
    create_vm "${SCRIPT_PATH}/${NODE_CONFIG}"
done

STACKIFY_VMS=$(echo ${STACKIFY_NODE_CONF} | sed "s/\.conf//g" | sed "s/,/ /g")
start_vms "${STACKIFY_VMS}"

Stackify
==========

Collection of simple scripts to get OpenStack POC up and running on VMs created using VirtualBox.

# What works

* 3 VirtualBox VMs created.
    * controller_node: 1CPU, 2GB RAM, 5GB Storage
    * network_node: 1CPU, 512MB RAM, 5GB Storage
    * compute_node: 1CPU, 2GB RAM, 10GB Storage
* First adapters of VMs are bridged so they have host/internet access.
* eth0 uses dynamic IP.
* No other adapter is configured.
* Unattended install is enabled via preseed/kickstart.
* Ubuntu Server 14.04.1 LTS is installed on 3 VMs.
* VMs started in headless mode.

# TODO

* Use Ansible to configure networking and other stuff on VMs.
* Create 2 NAT networks on VirtualBox.
    * management_network: 10.0.0.0/24
    * tunnel_network: 10.0.1.0/24
* Configure eth0 to use static IPs.
    * controller_node IP: 192.168.1.11
    * network_node IP: 192.168.1.21
    * compute_node IP: 192.168.1.31
* Configure networking to match OpenStack POC
    * controller_node: 1 NIC (10.0.0.11/24)
    * network_node: 2 NICs (10.0.0.21/24, 10.0.1.21/24)
    * compute_node: 2 NICs (10.0.0.31/24, 10.0.1.31/24)
* Deploy OpenStack components.

# Notes

OpenStack Storage components/network skipped for the timebeing.

# References

* VirtualBox
    * [vboxmanage] (https://www.virtualbox.org/manual/ch08.html)
    * [VirtualBox Networking] (https://www.virtualbox.org/manual/ch06.html)
* Preseed/Kickstart
    * [debian.org] (https://www.debian.org/releases/stable/i386/apb.html)
    * [askubuntu.com] (http://askubuntu.com/questions/122505/how-do-i-create-a-completely-unattended-install-of-ubuntu)
* Ansible
    * [ansible.com] (http://docs.ansible.com/intro.html)
* OpenStack
    * [Example Architectures#Minimal Architecture] (http://docs.openstack.org/juno/install-guide/install/apt/content/ch_overview.html#architecture_example-architectures)


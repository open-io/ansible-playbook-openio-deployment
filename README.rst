.. image:: https://travis-ci.org/open-io/ansible-playbook-openio-deployment.svg?branch=20.04
    :target: https://travis-ci.org/open-io/ansible-playbook-openio-deployment

Requirements
============

Hardware
--------

-  RAM: 2GB recommended

Operating system
----------------

-  Centos 7
-  Ubuntu 16.04 (Server)
-  Ubuntu 18.04 (Server)

System
------

-  `SELinux <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/selinux_users_and_administrators_guide/sect-security-enhanced_linux-working_with_selinux-changing_selinux_modes>`__ or `AppArmor <https://help.ubuntu.com/lts/serverguide/apparmor.html.en>`__ are disabled

  .. code-block:: shell

    # RedHat
    sudo sed -i -e 's@^SELINUX=enforcing$@SELINUX=disabled@g' /etc/selinux/config
    sudo setenforce 0
    sudo systemctl disable selinux.service

  .. code-block:: shell

    # Ubuntu
    sudo systemctl stop apparmor.service
    sudo update-rc.d -f apparmor remove

-  root privileges are required (using sudo)

  .. code-block:: shell

    # /etc/sudoers
    john    ALL=(ALL)    NOPASSWD: ALL

-  All nodes must have different hostnames
-  ``/var/lib`` partition must support Extended Attributes: XFS is recommended

  .. code-block:: shell

    [root@centos ~]# df /var/lib
    Filesystem     1K-blocks    Used Available Use% Mounted on
    /dev/vda1       41931756 1624148  40307608   4% /
    [root@centos ~]# file -sL /dev/vda1
    /dev/vda1: SGI XFS filesystem data (blksz 4096, inosz 512, v2 dirs)

-  System must be up-to-date

  .. code-block:: shell

    # RedHat
    sudo yum update -y
    sudo reboot

  .. code-block:: shell

    # Ubuntu
    sudo apt update -y
    sudo apt upgrade -y
    sudo reboot

Network
-------

-  All nodes connected to the same LAN through the specified interface (first one by default)
-  Firewall is disabled

  .. code-block:: shell

    # RedHat
    sudo systemctl stop firewalld.service
    sudo systemctl disable firewalld.service

  .. code-block:: shell

    # Ubuntu
    sudo ufw disable
    sudo systemctl disable ufw.service


Setup
-----

You only need to do this setup on the node that will install the others.

-  Install Ansible (`official guide <https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html>`__)
-  Install git for download requirements
-  Clone the OpenIO ansible playbook deployment repository (or download it with wget and unzip)

  .. code-block:: shell

    git clone https://github.com/open-io/ansible-playbook-openio-deployment.git oiosds


-  Install ``python-netaddr``

  .. code-block:: shell

    # RedHat
    sudo yum install git python-netaddr -y

  .. code-block:: shell

    # Ubuntu
    sudo apt install git python-netaddr -y


Now you can install `OpenIO SDS <https://github.com/open-io/ansible-playbook-openio-deployment/tree/20.04/products/sds>`__

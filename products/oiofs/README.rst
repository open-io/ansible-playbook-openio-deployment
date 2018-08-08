===================
OIOFS node install
===================

.. contents::
   :depth: 1
   :local:

Requirements
============

Licence
-------

-  A login and a password provided by OpenIO Support

Hardware
--------

-  Storage drive: A storage device for cache

Operating system
----------------

-  Centos 7
-  Ubuntu 16.04 (Server)

System
------

-  root privileges are required (using sudo)
-  `SELinux <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/selinux_users_and_administrators_guide/sect-security-enhanced_linux-working_with_selinux-changing_selinux_modes>`__ or `AppArmor <https://help.ubuntu.com/lts/serverguide/apparmor.html.en>`__ are disabled (managed at deployment)
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

-  This node connected to the same OIOSDS's lan

SDS
---

-  The conscience IP address
-  The namespace used
-  The redis sentinels addresses and the redis cluster name


Setup
-----

You only need to perform this setup on the node involved in the install (or your laptop)

-  Install Ansible (`official guide <https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html>`__)
-  Install ``git``

  .. code-block:: shell

    # RedHat
    sudo yum install git -y

  .. code-block:: shell

    # Ubuntu
    sudo apt install git -y

-  Clone the OpenIO ansible playbook deployment repository

  .. code-block:: shell

    git clone https://github.com/open-io/ansible-playbook-openio-deployment.git oiofs && cd oiosds/products/oiofs

Architecture
============

This playbook will deploy a oiofs mount connected to a SDS cluster

  .. code-block:: shell


          +---------+
          |         |
          |   +---------+                                                     +---------+
          |   |     |   |                                                     |         |
          |   |   +---------+                                                 |         |
          |   |   | |   |   |          Provide file-oriented access           |         |
          |   |   | |   |   |                                                 |         |
          |   |   | |   |   | <---------------------------------------------> |         |
          |   |   | |   |   |                                                 |         |
          |   |   | |   |   |          on an object storage backend           |         |
          +---------+   |   |                                                 |         |
              |   |     |   |                                                 |         |
              +---------+   |                                                 +---------+
      OpenIO SDS  |         |                                                  OpenIO FS
      (N-nodes)   +---------+




Installation
============

First you need to fill the inventory accordingly to your environment:

- Edit the ``inventories/01_oiofs.ini`` file and adapt the IP addresses and SSH user (sample here: `inventory <https://github.com/open-io/ansible-playbook-openio-deployment/blob/master/products/oiofs/inventories/01_oiofs.ini>`__)

  .. code-block:: shell

    [oiofs]
    node_oiofs ansible_host=10.0.0.1 ansible_user=root # Change it with the IP of the server
    ...

You can check that everything is well configured using this command:

  .. code-block:: shell

    ansible all -i inventories -bv -m ping

Run these commands:

-  To download and install requirements:

  .. code-block:: shell

    ./requirements_install.sh

- To deploy:

  .. code-block:: shell

    ansible-playbook -i inventories main.yml

Post-install Checks
===================

The node is configured and the filesystem is mounted

Run these commands on the node ``gridinit_cmd status`` and ``df -h``

Sample output:

::

  root@node1:/# gridinit_cmd status
  KEY                                            STATUS      PID GROUP
  OPENIO-ecd-0                                   UP         8383 OPENIO,ecd,0
  OPENIO-oiofs-mnt_oiofs_MY_CONTAINER_MY_ACCOUNT UP        10503 OPENIO,oiofs,mnt_oiofs_MY_CONTAINER_MY_ACCOUNT
  OPENIO-oioproxy-1                              UP         9148 OPENIO,oioproxy,1

  root@node1:/# df -h
  Filesystem      Size  Used Avail Use% Mounted on
  [...]
  oiofs-fuse       16E     0   16E   0% /mnt/oiofs-MY_CONTAINER-MY_ACCOUNT


Custom your deployment
======================

Credentials
-----------

You can set your credentials in the `oiofs.yml <https://github.com/open-io/ansible-playbook-openio-deployment/tree/master/products/oiofs/inventories/group_vars/oiofs.yml>`__ file.

.. code-block:: yaml
   :caption: oiofs.yml

   ---
   # Login provided by OPENIO
   openio_oiofs_customer_login: foo
   # Password provided by OPENIO
   openio_oiofs_customer_password: bar
   ...

SDS informations
----------------

You can set all your SDS informations in the  `oiofs.yml <https://github.com/open-io/ansible-playbook-openio-deployment/tree/master/products/oiofs/inventories/group_vars/oiofs.yml>`__ file.

By default, an ``ecd`` and an ``oioproxy`` are deployed on the target node and bind the default IP address.

.. code-block:: yaml
   :caption: oiofs.yml

   ---
   # Conscience SDS
   openio_sds_conscience_address: 172.17.0.4
   # Proxy SDS (deployed on oiofs nodes)
   openio_sds_oioproxy_address: "{{ ansible_default_ipv4.address }}"
   # Erasure Coding Daemon (deployed on oiofs nodes)
   openio_sds_ecd_address: "{{ ansible_default_ipv4.address }}"
   # Redis Cluster SDS
   openio_sds_sentinels_name: "{{ openio_sds_namespace }}-master-1"
   openio_sds_sentinels_addresses:
     - 172.17.0.2:6012
     - 172.17.0.3:6012
     - 172.17.0.4:6012
   ...

Manage mounts
-------------

All mounts are defined in the `oiofs.yml <https://github.com/open-io/ansible-playbook-openio-deployment/tree/master/products/oiofs/inventories/group_vars/oiofs.yml>`__ file and customized by host in the `node_oiofs.yml <https://github.com/open-io/ansible-playbook-openio-deployment/tree/master/products/oiofs/inventories/host_vars/node_oiofs.yml>`__ file.

.. code-block:: yaml
   :caption: oiofs.yml

   ---
   # List of oiofs mounts
   oiofs_mounts:
     - path: /mnt/oiofs-MY_CONTAINER-MY_ACCOUNT
       account: MY_ACCOUNT
       container: MY_CONTAINER
       retry_delay: 1000
       sds_retry_delay: 1000
       fuse_max_retries: 200
       max_flush_thread: "{{ ansible_processor_vcpus / 2 | int }}"
   ...

The ``node_oiofs.yml`` matches information defined in the ``oiofs.yml``

.. code-block:: yaml
   :caption: node_oiofs.yml

   ---
   oiofs_mountpoints:
       # this path to be define in 'oiofs_mounts'
     - path: /mnt/oiofs-MY_CONTAINER-MY_ACCOUNT
       cache_directory: /mnt/oiofs-MY_CONTAINER-MY_ACCOUNT.cache
       container: "{{ oiofs_mounts | selectattr('path', 'equalto', '/mnt/oiofs-MY_CONTAINER-MY_ACCOUNT') | map(attribute='container') | join }}"
       account: "{{ oiofs_mounts | selectattr('path', 'equalto', '/mnt/oiofs-MY_CONTAINER-MY_ACCOUNT') | map(attribute='account') | join }}"
       oioproxy_host: "{{ openio_sds_oioproxy_address }}"
       ecd_host: "{{ openio_sds_ecd_address }}"
       redis_sentinel_servers: '{{ openio_sds_sentinels_addresses | string | safe }}'
       redis_sentinel_name: "{{ openio_sds_sentinels_name }}"
       state: present
   ...


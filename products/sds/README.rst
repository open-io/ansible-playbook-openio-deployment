.. title:: Deploy a multi-node Swift/S3 on-premises object storage backend

.. _ref-install-guide:

========================
Multi Nodes Installation
========================

Install a three nodes on-premises object storage backend, using the deployment tools provided by OpenIO.

.. contents::
   :backlinks: none
   :depth: 1
   :local:


Requirements
============

Hardware
--------

When run as the backend layer, OpenIO SDS is lightweight and requires few resources.
The front layer consists of the gateways (Openstack Swift, Amazon S3) and their services do not require many resources.

- CPU: any dual core at 1 Ghz or faster
- RAM: 2GB recommended
- Network: 1Gb/s NIC

Operating system
----------------

As explained on our :ref:`label-support-linux` page, OpenIO supports the following distributions:

-  `Centos 7 <https://www.centos.org/>`_
-  `Ubuntu 16.04 (Server) <http://releases.ubuntu.com/releases/16.04/>`_, a.k.a. ``Xenial Xerus``
-  `Ubuntu 18.04 (Server) <http://releases.ubuntu.com/18.04/>`_, a.k.a ``Bionic Beaver``

System
------

-  Root privileges are required (using sudo).
-  `SELinux <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/selinux_users_and_administrators_guide/sect-security-enhanced_linux-working_with_selinux-changing_selinux_modes>`__ or `AppArmor <https://help.ubuntu.com/lts/serverguide/apparmor.html.en>`__ are disabled (managed at deployment).
-  All nodes must have different hostnames.
-  The ``/var/lib`` partition must support `extended attributes <http://man7.org/linux/man-pages/man7/xattr.7.html>`_. ``XFS`` is recommended.
-  The system must be up to date.

Check the presence and the type of the ``/var/lib`` partition. In this example, ``SGI XFS`` is the filesystem:

  .. code-block:: shell

    [root@centos ~]# df /var/lib
    Filesystem     1K-blocks    Used Available Use% Mounted on
    /dev/vda1       41931756 1624148  40307608   4% /
    [root@centos ~]# file -sL /dev/vda1
    /dev/vda1: SGI XFS filesystem data (blksz 4096, inosz 512, v2 dirs)

If you are running Centos or RedHat, keep your system up-to-date as follows:

  .. code-block:: shell

    # RedHat
    sudo yum update -y
    sudo reboot

If you are using Ubuntu or Debian, keep your system up-to-date as follows:

  .. code-block:: shell

    # Ubuntu
    sudo apt update -y
    sudo apt upgrade -y
    sudo reboot


Network
-------

-  All nodes are connected to the same LAN through the specified interface (the first one by default).
-  The firewall is disabled (this is managed at deployment).

  .. code-block:: shell

    # Ubuntu
    sudo sudo ufw disable
    sudo systemctl disable ufw.service


Setup
-----

You only need to perform this setup on one of the nodes in the cluster (or your laptop).

-  Install Ansible (`official guide <https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html>`__).
-  Install ``git`` and ``python-netaddr`` (this is managed at deployment).

  .. code-block:: shell

    # RedHat
    sudo yum install git -y

  .. code-block:: shell

    # Ubuntu
    sudo apt install git -y

-  Clone the OpenIO ansible playbook deployment repository

  .. code-block:: shell

    git clone https://github.com/open-io/ansible-playbook-openio-deployment.git --branch 18.10 oiosds && cd oiosds/products/sds

Architecture
============

This playbook will deploy a multi-nodes cluster as shown below:

  .. code-block:: shell


    +-----------------+   +-----------------+   +-----------------+
    |     OIOSWIFT    |   |     OIOSWIFT    |   |     OIOSWIFT    |
    |      FOR S3     |   |      FOR S3     |   |      FOR S3     |
    +-----------------+   +-----------------+   +-----------------+
    |      OPENIO     |   |      OPENIO     |   |      OPENIO     |
    |       SDS       |   |       SDS       |   |       SDS       |
    +-----------------+   +-----------------+   +-----------------+



Installation
============

First, configure the inventory according to your environment:

- Edit the ``inventory.ini`` file and with the IP addresses and SSH user (sample here: `inventory <https://github.com/open-io/ansible-playbook-openio-deployment/blob/18.10/products/sds/inventory.ini>`__).

  .. code-block:: shell

    [all]
    node1 ansible_host=10.0.0.1 # Change it with the IP of the first server
    node2 ansible_host=10.0.0.2 # Change it with the IP of the second server
    node3 ansible_host=10.0.0.3 # Change it with the IP of the third server
    ...

  .. code-block:: shell

    [all:vars]
    ansible_user=root # Change it accordingly

Ensure you have a ssh access to your nodes

  .. code-block:: shell

    # generate a ssh key
    $> ssh-keygen

    # copy the key on all nodes
    $> for node in <name-of-remote-server1> <name-of-remote-server2> <name-of-remote-server3>; do ssh-copy-id $node; done

    # start a ssh-agent
    $> eval "$(ssh-agent -s)"

    # add the key into the agent
    $> ssh-add .ssh/id_rsa

    # test connection without password
    $> ssh <name-of-remote-server1>

You can check that everything is configured correctly using this command:

  .. code-block:: shell

    # RedHat
    ansible all -i inventory.ini -bv -m ping

    # Ubuntu
    ansible all -i inventory.ini -bv -m ping -e 'ansible_python_interpreter=/usr/bin/python3'


Run these commands:

-  To download and install requirements:

  .. code-block:: shell

    ./requirements_install.sh

- To deploy and initialize the cluster:

  .. code-block:: shell

    ./deploy_and_bootstrap.sh

Post-installation checks
========================

All the nodes are configured to use openio-cli and aws-cli.

Run this check script on one of the nodes in the cluster ``sudo /root/checks.sh``.

Sample output:

::

  root@sds-cde-1:~# ./checks.sh
  ## OPENIO
   Status of services.
  KEY                         STATUS      PID GROUP
  OPENIO-account-0            UP        23724 OPENIO,account,0
  OPENIO-beanstalkd-0         UP        23725 OPENIO,beanstalkd,0
  OPENIO-conscienceagent-0    UP        23721 OPENIO,conscienceagent,0
  OPENIO-memcached-0          UP        23720 OPENIO,memcached,0
  OPENIO-meta0-0              UP        23772 OPENIO,meta0,0
  OPENIO-meta1-0              UP        23771 OPENIO,meta1,0
  OPENIO-meta2-0              UP        23770 OPENIO,meta2,0
  OPENIO-oio-blob-indexer-0   UP        23723 OPENIO,oio-blob-indexer,0
  OPENIO-oio-blob-rebuilder-0 UP        23722 OPENIO,oio-blob-rebuilder,0
  OPENIO-oio-event-agent-0    UP        23767 OPENIO,oio-event-agent,0
  OPENIO-oioproxy-0           UP        23773 OPENIO,oioproxy,0
  OPENIO-oioswift-0           UP        23719 OPENIO,oioswift,0
  OPENIO-rawx-0               UP        23769 OPENIO,rawx,0
  OPENIO-rdir-0               UP        23768 OPENIO,rdir,0
  OPENIO-redis-0              UP        23727 OPENIO,redis,0
  OPENIO-redissentinel-0      UP        23726 OPENIO,redissentinel,0
  OPENIO-zookeeper-0          UP        23728 OPENIO,zookeeper,0
  --
   Display the cluster status.
  +---------+----------------+------------+---------------------------------+-------------+-------+------+-------+
  | Type    | Addr           | Service Id | Volume                          | Location    | Slots | Up   | Score |
  +---------+----------------+------------+---------------------------------+-------------+-------+------+-------+
  | account | 10.0.1.11:6009 | n/a        | n/a                             | sds-cde-3.0 | n/a   | True |   100 |
  | account | 10.0.1.13:6009 | n/a        | n/a                             | sds-cde-2.0 | n/a   | True |    99 |
  | account | 10.0.1.14:6009 | n/a        | n/a                             | sds-cde-1.0 | n/a   | True |    70 |
  | meta0   | 10.0.1.11:6001 | n/a        | /var/lib/oio/sds/OPENIO/meta0-0 | sds-cde-3.0 | n/a   | True |   100 |
  | meta0   | 10.0.1.13:6001 | n/a        | /var/lib/oio/sds/OPENIO/meta0-0 | sds-cde-2.0 | n/a   | True |    99 |
  | meta0   | 10.0.1.14:6001 | n/a        | /var/lib/oio/sds/OPENIO/meta0-0 | sds-cde-1.0 | n/a   | True |    90 |
  | meta1   | 10.0.1.11:6110 | n/a        | /var/lib/oio/sds/OPENIO/meta1-0 | sds-cde-3.0 | n/a   | True |    93 |
  | meta1   | 10.0.1.13:6110 | n/a        | /var/lib/oio/sds/OPENIO/meta1-0 | sds-cde-2.0 | n/a   | True |    93 |
  | meta1   | 10.0.1.14:6110 | n/a        | /var/lib/oio/sds/OPENIO/meta1-0 | sds-cde-1.0 | n/a   | True |    92 |
  | meta2   | 10.0.1.11:6120 | n/a        | /var/lib/oio/sds/OPENIO/meta2-0 | sds-cde-3.0 | n/a   | True |    93 |
  | meta2   | 10.0.1.13:6120 | n/a        | /var/lib/oio/sds/OPENIO/meta2-0 | sds-cde-2.0 | n/a   | True |    93 |
  | meta2   | 10.0.1.14:6120 | n/a        | /var/lib/oio/sds/OPENIO/meta2-0 | sds-cde-1.0 | n/a   | True |    92 |
  | rawx    | 10.0.1.11:6200 | n/a        | /var/lib/oio/sds/OPENIO/rawx-0  | sds-cde-3.0 | n/a   | True |    93 |
  | rawx    | 10.0.1.13:6200 | n/a        | /var/lib/oio/sds/OPENIO/rawx-0  | sds-cde-2.0 | n/a   | True |    93 |
  | rawx    | 10.0.1.14:6200 | n/a        | /var/lib/oio/sds/OPENIO/rawx-0  | sds-cde-1.0 | n/a   | True |    93 |
  | rdir    | 10.0.1.11:6300 | n/a        | /var/lib/oio/sds/OPENIO/rdir-0  | sds-cde-3.0 | n/a   | True |   100 |
  | rdir    | 10.0.1.13:6300 | n/a        | /var/lib/oio/sds/OPENIO/rdir-0  | sds-cde-2.0 | n/a   | True |    99 |
  | rdir    | 10.0.1.14:6300 | n/a        | /var/lib/oio/sds/OPENIO/rdir-0  | sds-cde-1.0 | n/a   | True |    70 |
  +---------+----------------+------------+---------------------------------+-------------+-------+------+-------+
  --
   Upload the /etc/passwd file to the bucket MY_CONTAINER of the project MY_ACCOUNT.
  +--------+------+----------------------------------+--------+
  | Name   | Size | Hash                             | Status |
  +--------+------+----------------------------------+--------+
  | passwd | 1996 | 420C3FC20631F95B6EED50E7423295F6 | Ok     |
  +--------+------+----------------------------------+--------+
  --
   Get some information about your object.
  +----------------+--------------------------------------------------------------------+
  | Field          | Value                                                              |
  +----------------+--------------------------------------------------------------------+
  | account        | MY_ACCOUNT                                                         |
  | base_name      | 7B1F1716BE955DE2D677B68819836E4F75FD2424F6D22DB60F9F2BB40331A741.1 |
  | bytes_usage    | 1.996KB                                                            |
  | container      | MY_CONTAINER                                                       |
  | ctime          | 1540562156                                                         |
  | max_versions   | Namespace default                                                  |
  | objects        | 1                                                                  |
  | quota          | Namespace default                                                  |
  | status         | Enabled                                                            |
  | storage_policy | Namespace default                                                  |
  +----------------+--------------------------------------------------------------------+
  --
   List objects in container.
  +--------+------+----------------------------------+------------------+
  | Name   | Size | Hash                             |          Version |
  +--------+------+----------------------------------+------------------+
  | passwd | 1996 | 420C3FC20631F95B6EED50E7423295F6 | 1540562156802496 |
  +--------+------+----------------------------------+------------------+
  --
   Find the services used by your container.
  +-----------------+--------------------------------------------------------------------+
  | Field           | Value                                                              |
  +-----------------+--------------------------------------------------------------------+
  | account         | MY_ACCOUNT                                                         |
  | base_name       | 7B1F1716BE955DE2D677B68819836E4F75FD2424F6D22DB60F9F2BB40331A741.1 |
  | meta0           | 10.0.1.11:6001, 10.0.1.13:6001, 10.0.1.14:6001                     |
  | meta1           | 10.0.1.11:6110, 10.0.1.13:6110, 10.0.1.14:6110                     |
  | meta2           | 10.0.1.11:6120, 10.0.1.14:6120, 10.0.1.13:6120                     |
  | meta2.sys.peers | 10.0.1.11:6120, 10.0.1.13:6120, 10.0.1.14:6120                     |
  | name            | MY_CONTAINER                                                       |
  | status          | Enabled                                                            |
  +-----------------+--------------------------------------------------------------------+
  --
   Save the data stored in the given object to the --file destination.
  root:x:0:0:root:/root:/bin/bash
  daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
  bin:x:2:2:bin:/bin:/usr/sbin/nologin
  sys:x:3:3:sys:/dev:/usr/sbin/nologin
  sync:x:4:65534:sync:/bin:/bin/sync
  games:x:5:60:games:/usr/games:/usr/sbin/nologin
  man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
  lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
  mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
  news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
  --
   Show account informations.
  +------------+------------+
  | Field      | Value      |
  +------------+------------+
  | account    | MY_ACCOUNT |
  | bytes      | 1.996KB    |
  | containers | 1          |
  | ctime      | 1540497830 |
  | metadata   | {}         |
  | objects    | 1          |
  +------------+------------+
  --
   Delete your object.
  +--------+---------+
  | Name   | Deleted |
  +--------+---------+
  | passwd | True    |
  +--------+---------+
  --
   Delete your empty container.
  --

  ------
  ## AWS
   Create a bucket mybucket.
  make_bucket: mybucket
  --
   Upload the /etc/passwd file to the bucket mybucket.
  upload: ../etc/passwd to s3://mybucket/passwd
  --
   List your buckets.
  2018-10-26 13:56:00    1.9 KiB passwd

  Total Objects: 1
     Total Size: 1.9 KiB
  --
   Save the data stored in the given object to the specified file.
  download: s3://mybucket/passwd to ../tmp/passwd.aws
  root:x:0:0:root:/root:/bin/bash
  daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
  bin:x:2:2:bin:/bin:/usr/sbin/nologin
  sys:x:3:3:sys:/dev:/usr/sbin/nologin
  sync:x:4:65534:sync:/bin:/bin/sync
  games:x:5:60:games:/usr/games:/usr/sbin/nologin
  man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
  lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
  mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
  news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
  --
   Delete your object.
  delete: s3://mybucket/passwd
  --
   Delete your empty bucket.
  remove_bucket: mybucket
  --
  Done !

  ++++
   AWS S3 summary:
    endpoint: http://10.0.1.14:6007
    region: us-east-1
    access key: demo:demo
    secret key: DEMO_PASS
    ssl: false
    signature_version: s3v4
    path style: true


Manual requirements
===================

This deployment is designed to be as simple as possible.
Set ``openio_manage_os_requirement`` to ``false`` in the file `all.yml <https://github.com/open-io/ansible-playbook-openio-deployment/blob/18.10/products/sds/group_vars/all.yml>`__ if you wish to manually manage your requirements.

SELinux and AppArmor
--------------------

`SELinux <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/selinux_users_and_administrators_guide/sect-security-enhanced_linux-working_with_selinux-changing_selinux_modes>`__ or `AppArmor <https://help.ubuntu.com/lts/serverguide/apparmor.html.en>`__ must be disabled:

  .. code-block:: shell

    # RedHat
    sudo sed -i -e 's@^SELINUX=enforcing$@SELINUX=disabled@g' /etc/selinux/config
    sudo setenforce 0
    sudo systemctl disable selinux.service

  .. code-block:: shell

    # Ubuntu
    sudo service apparmor stop
    sudo apparmor teardown
    sudo update-rc.d -f apparmor remove

Firewall
--------

The firewall must be disabled:

  .. code-block:: shell

    # RedHat
    sudo systemctl stop firewalld.service
    sudo systemctl disable firewalld.service

  .. code-block:: shell

    # Ubuntu
    sudo sudo ufw disable
    sudo systemctl disable ufw.service

Proxy
-----

Set your variables environment in the file `all.yml <https://github.com/open-io/ansible-playbook-openio-deployment/blob/18.10/products/sds/group_vars/all.yml>`__.

  .. code-block:: shell

    openio_environment:
      http_proxy: http://proxy.example.com:8080
      https_proxy: http://proxy.bos.example.com:8080

Customizing your deployment
===========================

Manage NTP configuration
------------------------

You can set the time settings in the `all.yml <https://github.com/open-io/ansible-playbook-openio-deployment/blob/18.10/products/sds/group_vars/all.yml>`__ file.
By default, the deployment does not change your timezone but enable the NTP service and set four NTP servers

.. code-block:: yaml
   :caption: all.yml

   ---
   # NTP
   ntp_enabled: true
   ntp_manage_config: true
   ntp_manage_timezone: false
   ntp_timezone: "Etc/UTC"
   ntp_area: ""
   ntp_servers:
     - "0{{ ntp_area }}.pool.ntp.org iburst"
     - "1{{ ntp_area }}.pool.ntp.org iburst"
     - "2{{ ntp_area }}.pool.ntp.org iburst"
     - "3{{ ntp_area }}.pool.ntp.org iburst"
   ntp_restrict:
     - "127.0.0.1"
     - "::1"
   ...

If needed, you can add your own settings:

.. code-block:: yaml
   :caption: all.yml

   ---
   # NTP
   ntp_enabled: true
   ntp_manage_config: true
   ntp_manage_timezone: true
   ntp_timezone: "Europe/Paris"
   ntp_area: ".fr"
   ntp_servers:
     - "0{{ ntp_area }}.pool.ntp.org iburst"
     - "1{{ ntp_area }}.pool.ntp.org iburst"
     - "2{{ ntp_area }}.pool.ntp.org iburst"
     - "3{{ ntp_area }}.pool.ntp.org iburst"
   ntp_restrict:
     - "127.0.0.1"
     - "::1"
   ...

Manage storage volumes
----------------------

You can customize all storage devices by node in the `host_vars <https://github.com/open-io/ansible-playbook-openio-deployment/tree/18.10/products/sds/host_vars>`__ folder.
In this example, the nodes have two mounted volumes to store data and one to store metadata:

.. code-block:: yaml
   :caption: node1.yml

   ---
   openio_data_mounts:
     - { partition: '/dev/sdb', mountpoint: "/mnt/sda1" }
     - { partition: '/dev/sdc', mountpoint: "/mnt/sda2" }
   openio_metadata_mounts:
     - { partition: '/dev/sdd', mountpoint: "/mnt/ssd1" }
   ...

Manage the ssh connection
-------------------------

If your nodes don't all have the same ssh user configured, you can define a specific ssh user (or key) for the deployment of each node.

.. code-block:: yaml
   :caption: node1.yml

   ---
   ansible_user: my_user
   ansible_ssh_private_key_file: /home/john/.ssh/id_rsa
   #ansible_port: 2222
   #ansible_python_interpreter: /usr/local/bin/python
   ...

Manage the data network interface used
--------------------------------------

The interface used for data is defined by ``openio_bind_interface`` in the `openio.yml <https://github.com/open-io/ansible-playbook-openio-deployment/blob/18.10/products/sds/group_vars/openio.yml>`__. You can define a specific interface for a node in its ``host_vars`` file.

.. code-block:: yaml
   :caption: node1.yml

   ---
   openio_bind_interface: eth2
   ...

Manage the data network interface
---------------------------------

If you prefer to define each IP address instead of using a global interface, you can set it in the ``host_vars`` files.

.. code-block:: yaml
  :caption: node1.yml

  ---
  openio_bind_interface: "bond0"
  openio_bind_address: "{{ ansible_bond0.ipv4.address }}"
  ...

Manage S3 authentification
--------------------------

Set ``name``, ``password``, and ``role`` in `openio.yml <https://github.com/open-io/ansible-playbook-openio-deployment/blob/18.10/products/sds/group_vars/openio.yml>`__.

.. code-block:: yaml
  :caption: openio.yml

  ---
  # S3 users
  openio_oioswift_users:
    - name: "demo:demo"
      password: "DEMO_PASS"
      roles:
        - member
    - name: "test:tester"
      password: "testing"
      roles:
        - member
        - reseller_admin
  ...

Docker nodes
------------

If you don't have physical nodes to test our solution, you can spawn some *Docker* containers with the script provided.

.. code-block:: shell
  :caption: Example:

  $ ./spawn_my_lab.sh 3
  Replace with the following in the file named "inventory.ini"
  [all]
  node1 ansible_host=11ce9e9fecde ansible_user=root ansible_connection=docker
  node2 ansible_host=12cd8e2fxdel ansible_user=root ansible_connection=docker
  node3 ansible_host=13fe6e4ehier ansible_user=root ansible_connection=docker

  Change the variables in group_vars/openio.yml and adapt them to your host capacity

Architecture
============

You have to choose your cluster architecture:

- N-Node (at least 3) for a storage policy in '3 copies'
- Standalone node (all in one)

Installation
============

If you don't have physical nodes to test our solution, you can spawn some *docker* containers with the script provided

.. code-block:: shell

  $ ./spawn_my_lab.sh
  Replace with the following in the file named "01_inventory.ini"
  [all]
  node1 ansible_host=3a67d33f8f13 ansible_user=root ansible_connection=docker
  node2 ansible_host=deda882da891 ansible_user=root ansible_connection=docker
  node3 ansible_host=83d6ece9ee9d ansible_user=root ansible_connection=docker

  Change the variables in group_vars/openio.yml and adapt to your host capacity

After filling the inventory corresponding to your choice:

- For a N (at least 3) nodes:

  - `inventory <https://github.com/open-io/ansible-playbook-openio-deployment/blob/master/products/sds/inventories/n-nodes/01_inventory.ini>`__ (Adapt IP address and user ssh)
  - `OpenIO configuration <https://github.com/open-io/ansible-playbook-openio-deployment/blob/master/products/sds/inventories/n-nodes/group_vars/openio.yml>`__
- For a standalone node:

  - `inventory <https://github.com/open-io/ansible-playbook-openio-deployment/blob/master/products/sds/inventories/standalone/01_inventory.ini>`__ (Adapt IP address and user ssh)
  - `OpenIO configuration <https://github.com/open-io/ansible-playbook-openio-deployment/blob/master/products/sds/inventories/standalone/group_vars/openio.yml>`__

You can check your customization like this:

.. code-block:: shell

  ansible all -i inventories/<YOUR_CHOICE> -bv -m ping
  #example: ansible all -i inventories/n-nodes -bv -m ping

Run these commands:

-  To download and install requirements:

  .. code-block:: shell

      ./requirements_install.sh

- To deploy:

  .. code-block:: shell

    ansible-playbook -i inventories/<YOUR_CHOICE> main.yml

Post-install Checks
===================

All the nodes are configured to easily use the openio-cli and aws-cli.

Log into one node and run the after install check script ``/root/checks.sh``


Sample output:


::

  [root@5bdc8fbc3ceb ~]# pwd
  /root
  [root@5bdc8fbc3ceb ~]# ./checks.sh
  ## OPENIO
   Status of services. 
  KEY                       STATUS      PID GROUP
  OPENIO-account-0          UP         2256 OPENIO,account,0
  OPENIO-beanstalkd-1       UP         4632 OPENIO,beanstalkd,beanstalkd-1
  OPENIO-conscience-1       UP         4809 OPENIO,conscience,conscience-1
  OPENIO-conscienceagent-1  UP         4619 OPENIO,conscienceagent,conscienceagent-1
  OPENIO-ecd-0              UP         7055 OPENIO,ecd,0
  OPENIO-memcached-0        UP         7466 OPENIO,memcached,0
  OPENIO-meta0-1            UP         5605 OPENIO,meta0,meta0-1
  OPENIO-meta1-1            UP         5581 OPENIO,meta1,meta1-1
  OPENIO-meta2-1            UP         4798 OPENIO,meta2,meta2-1
  OPENIO-oio-blob-indexer-1 UP         4788 OPENIO,oio-blob-indexer,oio-blob-indexer-1
  OPENIO-oio-event-agent-0  UP         4810 OPENIO,oio-event-agent,oio-event-agent-0
  OPENIO-oioproxy-1         UP         4843 OPENIO,oioproxy,oioproxy-1
  OPENIO-oioswift-0         UP         8959 OPENIO,oioswift,0
  OPENIO-rawx-1             UP         4702 OPENIO,rawx,rawx-1
  OPENIO-rdir-1             UP         4813 OPENIO,rdir,rdir-1
  OPENIO-redis-1            UP         4714 OPENIO,redis,redis-1
  OPENIO-redissentinel-1    UP         4686 OPENIO,redissentinel,redissentinel-1
  OPENIO-zookeeper-0        UP         3595 OPENIO,zookeeper,0
  --
   Display the cluster status. 
  +---------+-----------------+------------+---------------------------------+----------+-------+------+-------+
  | Type    | Addr            | Service Id | Volume                          | Location | Slots | Up   | Score |
  +---------+-----------------+------------+---------------------------------+----------+-------+------+-------+
  | account | 172.17.0.3:6009 | n/a        | n/a                             | node2    | n/a   | True |    99 |
  | account | 172.17.0.4:6009 | n/a        | n/a                             | node3    | n/a   | True |    95 |
  | account | 172.17.0.2:6009 | n/a        | n/a                             | node1    | n/a   | True |    95 |
  | meta0   | 172.17.0.3:6001 | n/a        | /var/lib/oio/sds/OPENIO/meta0-1 | node2    | n/a   | True |    97 |
  | meta0   | 172.17.0.4:6001 | n/a        | /var/lib/oio/sds/OPENIO/meta0-1 | node3    | n/a   | True |    97 |
  | meta0   | 172.17.0.2:6001 | n/a        | /var/lib/oio/sds/OPENIO/meta0-1 | node1    | n/a   | True |    97 |
  | meta1   | 172.17.0.3:6111 | n/a        | /var/lib/oio/sds/OPENIO/meta1-1 | node2    | n/a   | True |    68 |
  | meta1   | 172.17.0.4:6111 | n/a        | /var/lib/oio/sds/OPENIO/meta1-1 | node3    | n/a   | True |    68 |
  | meta1   | 172.17.0.2:6111 | n/a        | /var/lib/oio/sds/OPENIO/meta1-1 | node1    | n/a   | True |    68 |
  | meta2   | 172.17.0.3:6121 | n/a        | /var/lib/oio/sds/OPENIO/meta2-1 | node2    | n/a   | True |    68 |
  | meta2   | 172.17.0.4:6121 | n/a        | /var/lib/oio/sds/OPENIO/meta2-1 | node3    | n/a   | True |    68 |
  | meta2   | 172.17.0.2:6121 | n/a        | /var/lib/oio/sds/OPENIO/meta2-1 | node1    | n/a   | True |    68 |
  | rawx    | 172.17.0.3:6201 | n/a        | /var/lib/oio/sds/OPENIO/rawx-1  | node2    | n/a   | True |    68 |
  | rawx    | 172.17.0.4:6201 | n/a        | /var/lib/oio/sds/OPENIO/rawx-1  | node3    | n/a   | True |    68 |
  | rawx    | 172.17.0.2:6201 | n/a        | /var/lib/oio/sds/OPENIO/rawx-1  | node1    | n/a   | True |    68 |
  | rdir    | 172.17.0.3:6301 | n/a        | /var/lib/oio/sds/OPENIO/rdir-1  | node2    | n/a   | True |    95 |
  | rdir    | 172.17.0.4:6301 | n/a        | /var/lib/oio/sds/OPENIO/rdir-1  | node3    | n/a   | True |    95 |
  | rdir    | 172.17.0.2:6301 | n/a        | /var/lib/oio/sds/OPENIO/rdir-1  | node1    | n/a   | True |    95 |
  +---------+-----------------+------------+---------------------------------+----------+-------+------+-------+
  --
   Upload the /etc/passwd into the bucket MY_CONTAINER of the MY_ACCOUNT project. 
  +--------+------+----------------------------------+--------+
  | Name   | Size | Hash                             | Status |
  +--------+------+----------------------------------+--------+
  | passwd | 1246 | D39F219BF5875D561DAFB2B789CD1C6C | Ok     |
  +--------+------+----------------------------------+--------+
  --
   Get some informations about your object. 
  +----------------+--------------------------------------------------------------------+
  | Field          | Value                                                              |
  +----------------+--------------------------------------------------------------------+
  | account        | MY_ACCOUNT                                                         |
  | base_name      | 7B1F1716BE955DE2D677B68819836E4F75FD2424F6D22DB60F9F2BB40331A741.1 |
  | bytes_usage    | 1.246KB                                                            |
  | container      | MY_CONTAINER                                                       |
  | ctime          | 1532587799                                                         |
  | max_versions   | Namespace default                                                  |
  | objects        | 1                                                                  |
  | quota          | Namespace default                                                  |
  | status         | Enabled                                                            |
  | storage_policy | Namespace default                                                  |
  +----------------+--------------------------------------------------------------------+
  --
   List object in container. 
  +--------+------+----------------------------------+------------------+
  | Name   | Size | Hash                             |          Version |
  +--------+------+----------------------------------+------------------+
  | passwd | 1246 | D39F219BF5875D561DAFB2B789CD1C6C | 1532587799384608 |
  +--------+------+----------------------------------+------------------+
  --
   Find the services involved for your container. 
  +-----------+--------------------------------------------------------------------+
  | Field     | Value                                                              |
  +-----------+--------------------------------------------------------------------+
  | account   | MY_ACCOUNT                                                         |
  | base_name | 7B1F1716BE955DE2D677B68819836E4F75FD2424F6D22DB60F9F2BB40331A741.1 |
  | meta0     | 172.17.0.3:6001, 172.17.0.4:6001, 172.17.0.2:6001                  |
  | meta1     | 172.17.0.2:6111, 172.17.0.3:6111, 172.17.0.4:6111                  |
  | meta2     | 172.17.0.3:6121, 172.17.0.4:6121, 172.17.0.2:6121                  |
  | name      | MY_CONTAINER                                                       |
  | status    | Enabled                                                            |
  +-----------+--------------------------------------------------------------------+
  --
   Save the data stored in the given object to the --file destination. 
  root:x:0:0:root:/root:/bin/bash
  bin:x:1:1:bin:/bin:/sbin/nologin
  daemon:x:2:2:daemon:/sbin:/sbin/nologin
  adm:x:3:4:adm:/var/adm:/sbin/nologin
  lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
  sync:x:5:0:sync:/sbin:/bin/sync
  shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
  halt:x:7:0:halt:/sbin:/sbin/halt
  mail:x:8:12:mail:/var/spool/mail:/sbin/nologin
  operator:x:11:0:operator:/root:/sbin/nologin
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
   AWSCli credentials used. 
  [default]
  aws_access_key_id = demo:demo
  aws_secret_access_key = DEMO_PASS
  --
   Create a bucket mybucket. 
  make_bucket: mybucket
  --
   Upload the /etc/passwd into the bucket mybucket. 
  upload: ../etc/passwd to s3://mybucket/passwd                   
  --
   List your buckets. 
  2018-07-26 08:50:07    1.2 KiB passwd
  
  Total Objects: 1
     Total Size: 1.2 KiB
  --
   Save the data stored in the given object into the file given. 
  download: s3://mybucket/passwd to ../tmp/passwd.aws            
  root:x:0:0:root:/root:/bin/bash
  bin:x:1:1:bin:/bin:/sbin/nologin
  daemon:x:2:2:daemon:/sbin:/sbin/nologin
  adm:x:3:4:adm:/var/adm:/sbin/nologin
  lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
  sync:x:5:0:sync:/sbin:/bin/sync
  shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
  halt:x:7:0:halt:/sbin:/sbin/halt
  mail:x:8:12:mail:/var/spool/mail:/sbin/nologin
  operator:x:11:0:operator:/root:/sbin/nologin
  --
   Delete your object. 
  delete: s3://mybucket/passwd
  --
   Delete your empty bucket. 
  remove_bucket: mybucket
  
  Done


Low capacity nodes
==================

For many use cases (ARM, docker, ...), it can be useful to lower the default resource usage of some components.
Check `group\_vars\/openio.yml <https://github.com/open-io/ansible-playbook-openio-deployment/blob/master/products/sds/inventories/n-nodes/group_vars/openio.yml>`__ , you'll find a section to uncomment.

Disclaimer
==========

Please keep in mind that this guide is not intended for production, use it for demo/POC/development purposes only.

**Don't go in production with this setup.**

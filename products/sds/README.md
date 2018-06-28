# Architecture

You have to choose your POC architecture:
* N-Node (at least 3) for a storage policy in `3 copies`
* Standalone node (all in one)

# Installation

After filling the inventory corresponding to your choice
* For a N/3 nodes :
** [inventory](inventories/n-nodes/01_inventory.ini) 
** [OpenIO configuration](inventories/n-nodes/group_vars/openio.yml)
* For a uniq node :
** [inventory](inventories/standalone/01_inventory.ini) 
** [OpenIO configuration](inventories/standalone/group_vars/openio.yml)

You can run these commands: 
* `./requirements_install.sh` for download requirements
* `ansible-playbook -i inventories/<YOUR_CHOICE>/ main.yml` for deploy

# Test

All the nodes are configured to easily use the openio-cli and aws-clI.

Log you into one node and type:
 - OPENIO

	 -  `openio cluster list` for display the cluster status
	 -  `openio object create MY_CONTAINER /etc/passwd --oio-account MY_ACCOUNT` for upload the `/etc/passwd` into the bucket `MY_CONTAINER` of the `MY_ACCOUNT` project
	 -  `openio object show MY_CONTAINER passwd --oio-account MY_ACCOUNT` to get some informations about your object
	 -  `openio object locate MY_CONTAINER  passwd --oio-account MY_ACCOUNT` for display the distribution of your object
	 -  `openio container show MY_CONTAINER --oio-account MY_ACCOUNT` to get some informations about your container
	 -  `openio container locate MY_CONTAINER --oio-account MY_ACCOUNT` to find the services involved for your container
	 -  `openio object save MY_CONTAINER passwd --oio-account MY_ACCOUNT --file /tmp/passwd` for save the data stored in the given object to the `--file` destination
	 -  `openio container delete MY_CONTAINER passwd --oio-account MY_ACCOUNT` for delete your object
	 -  `openio container delete MY_CONTAINER --oio-account MY_ACCOUNT` for delete your empty container


 - For AWS, you have to replace the MY_IP by an IP address of your cluster
	 -  `aws --endpoint-url http://MY_IP:6007 --no-verify-ssl s3api create-bucket --bucket mycontainer` for create a bucket `mycontainer`
	 -  `aws --endpoint-url http://MY_IP:6007 --no-verify-ssl s3 cp /etc/passwd s3://mycontainer` for upload the `/etc/passwd` into the bucket `mycontainer`
	 -  `aws --endpoint-url http://MY_IP:6007 --no-verify-ssl s3 ls s3://mycontainer --recursive --human-readable --summarize` to list your container
	 -  `aws --endpoint-url http://MY_IP:6007 --no-verify-ssl s3 cp s3://mycontainer /tmp/passwd` for save the data stored in the given object into the file given
	 -  `aws --endpoint-url http://MY_IP:6007 --no-verify-ssl s3 rm s3://mycontainer/passwd` for delete your object
	 -  `aws --endpoint-url http://MY_IP:6007 --no-verify-ssl s3 rb s3://mycontainer` for delete your empty container

# Low capacity nodes

For many use cases (ARM, docker, ...), it can be useful to reduce the consumption of some components.
In the group_vars `openio.yml`, you'll find a section to uncomment.

# Disclaimer

Please keep in mind that deployment allows you to install OpenIO for demo/POC/development purposes only. Don't go in production with this setup.

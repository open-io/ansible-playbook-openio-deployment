# Requirements

## Hardware
* RAM: 2GB recommended

## Operating system
* Centos 7
* Ubuntu 16.04 (Server)

## System
* [SELinux](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/selinux_users_and_administrators_guide/sect-security-enhanced_linux-working_with_selinux-changing_selinux_modes) or [AppArmor](https://help.ubuntu.com/lts/serverguide/apparmor.html.en) are disabled
* root privileges are required (using sudo)
* All nodes must have different hostnames
* `/var/lib` partition must support Extended Attributes: XFS is recommended
* All have to be up-to-date `yum update -y` or `apt update -y && apt upgrade -y`

## Network
* All nodes connected to the same LAN through the specified interface (first one by default)
* Firewall is disabled

## Setup
* Clone this repository (or download it with wget and unzip)
* Install Ansible as [describe](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
* Install git for download requirements

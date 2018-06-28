# Requirements

## Hardware
* RAM: 2GB recommended

## Operating system
* Centos 7
* Ubuntu 16.04 (Server)

## System
* SELinux or AppArmor are disabled
* root privileges are required (using sudo)
* All nodes must have different hostnames
* `/var/lib` partition must support Extended Attributes: XFS is recommended

## Network
* All nodes connected to the same LAN through the specified interface (first one by default)
* Firewall is disabled

## Setup
* Clone this repository 
* Install Ansible as [describe](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

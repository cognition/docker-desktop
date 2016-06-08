#!/bin/bash


echo "start Services"
# restarts the xdm service
/etc/init.d/xdm restart

# Start the ssh service
/usr/sbin/sshd -D

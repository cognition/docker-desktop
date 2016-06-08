#!/bin/bash


echo "start Services"
echo "Start the xdm service"
/etc/init.d/xdm start

echo "Start the ssh service"
/usr/sbin/sshd -D

#!/bin/bash

# Environment Var for Username
USER=${USER:-"docker"}



if [ -f .setup_done ]; then
  echo "Container Already Initialized"
  /bin/sh -c  /src/run.sh &
  exit 0
fi



# Create the directory needed to run the sshd daemon
mkdir /var/run/sshd 

# Add docker user and generate a random password with 12 characters that includes at least one capital letter and number.
DOCKER_PASSWORD=`pwgen -c -n -1 12`
echo User: $USER Password: $DOCKER_PASSWORD
DOCKER_ENCRYPYTED_PASSWORD=`perl -e 'print crypt('"$DOCKER_PASSWORD"', "aa"),"\n"'`
useradd -m --shell=/bin/bash -d /home/$USER -p $DOCKER_ENCRYPYTED_PASSWORD $USER
sed -Ei "s/adm:x:4:/${USER}:x:4:${USER}/" /etc/group
adduser $SUSER sudo

# Set the default shell as bash for docker user.
chgrp $USER: /opt
chmod  775 /opt

# Copy the config files into the docker directory
cd /src/config/ && sudo -u $USER cp -R .[a-z]* [a-z]* /home/$USER/
echo "$USER  ALL=(ALL:ALL) NOPASSWD:  ALL" > /etc/sudoers.d/$USER


touch /.setup_done
echo "Setup is done" 
echo "start Services" 
/bin/sh -c  /src/run.sh &

exit 0


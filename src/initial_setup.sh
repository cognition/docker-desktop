#!/bin/bash

# Environment Var for Username
USER=${USER:-"docker"}



if [ -f .setup_done ]; then
  echo "Container Already Initialized"
  exit 0
fi



# Create the directory needed to run the sshd daemon
mkdir /var/run/sshd 

# Add docker user and generate a random password with 12 characters that includes at least one capital letter and number.
DOCKER_PASSWORD=`pwgen -c -n -1 12`
echo User: $USER Password: $DOCKER_PASSWORD
DOCKER_ENCRYPYTED_PASSWORD=`perl -e 'print crypt('"$DOCKER_PASSWORD"', "aa"),"\n"'`
useradd -m --shell=/bin/bash -d /home/docker -p $DOCKER_ENCRYPYTED_PASSWORD $USER
sed -Ei 's/adm:x:4:/docker:x:4:docker/' /etc/group
adduser docker sudo

# Set the default shell as bash for docker user.
#chsh -s /bin/bash $USER

# Copy the config files into the docker directory
cd /src/config/ && sudo -u $USER cp -R .[a-z]* [a-z]* /home/$USER/
echo "$USER  ALL=(ALL:ALL) NOPASSWD:  ALL" > /etc/sudoers.d/$USER


touch /.setup_done
echo "Setup is done" 

exit 0


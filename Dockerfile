## This file creates a container that runs X11 and SSH services
## The ssh is used to forward X11 and provide you encrypted data
## communication between the docker container and your local 
## machine.
##
## Xpra allows to display the programs running inside of the
## container such as Firefox, LibreOffice, xterm, etc. 
## with disconnection and reconnection capabilities
##
## Xephyr allows to display the programs running inside of the
## container such as Firefox, LibreOffice, xterm, etc. 
##
## Fluxbox and ROX-Filer creates a very minimalist way to 
## manages the windows and files.
##
## Author: Roberto Gandolfo Hashioka
## Date: 07/28/2013
## Forked From Roberto G. Hashioka "roberto_hashioka@hotmail.com"
## Date: 06/04/2016
#
FROM ubuntu
MAINTAINER Ramon Brooker <rbrooker@aetherealmind.com>
#
## Set the env variable DEBIAN_FRONTEND to noninteractive
ENV DEBIAN_FRONTEND noninteractive
#
RUN echo exit 1 > /usr/sbin/policy-rc.d; chmod +x /usr/sbin/policy-rc.d
#
## running the update key to fix the issue of ClearSign 
RUN apt-key update && apt-get update  ;  apt-get upgrade -y 
#
## Installing the environment required: xserver, xdm, flux box, roc-filer and ssh
RUN apt-get install -y xpra rox-filer openssh-server pwgen xserver-xephyr xdm fluxbox xvfb sudo wget build-essential default-jdk git curl autoconf unzip zip zlib1g-dev gawk gperf cmake git lib32stdc++6 lib32z1 lib32z1-dev bash-completion expect gcc-4.8 apt-get utils xterm synaptic net-tools vim  
#
#ADD https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz   /
#ADD http://dl.google.com/android/repository/android-ndk-r11c-linux-x86_64.zip /
#
#
## Configuring xdm to allow connections from any IP address and ssh to allow X11 Forwarding. 
RUN sed -i 's/DisplayManager.requestPort/!DisplayManager.requestPort/g' /etc/X11/xdm/xdm-config
RUN sed -i '/#any host/c\*' /etc/X11/xdm/Xaccess
RUN ln -sf /usr/bin/Xorg /usr/bin/X
RUN echo X11Forwarding yes >> /etc/ssh/ssh_config
#
## Fix PAM login issue with sshd
RUN sed -i 's/session    required     pam_loginuid.so/#session    required     pam_loginuid.so/g' /etc/pam.d/sshd
#
## Upstart and DBus have issues inside docker. We work around in order to install firefox.
RUN dpkg-divert --local --rename --add /sbin/initctl && ln -sf /bin/true /sbin/initctl
#
## Installing fuse package (libreoffice-java dependency) and it's going to try to create
## a fuse device without success, due the container permissions. || : help us to ignore it. 
## Then we are going to delete the postinst fuse file and try to install it again!
## Thanks Jerome for helping me with this workaround solution! :)
## Now we are able to install the libreoffice-java package  
#
RUN apt-get -y install fuse  || :
RUN rm -rf /var/lib/dpkg/info/fuse.postinst
RUN apt-get -y install fuse
#
## Installing the apps: Firefox 
RUN apt-get install -y firefox
#
## Set locale (fix the locale warnings)
RUN localedef -v -c -i en_US -f UTF-8 en_US.UTF-8 || :
#
## Copy the files into the container
ADD . /src
#
## Set Time Stamp of Build
ADD set-time.sh  /set-time.sh
RUN  /set-time.sh
#
#
EXPOSE 22
## Start xdm and ssh services.
#CMD ["/bin/bash"]
CMD ["/bin/bash", "/src/run.sh"]

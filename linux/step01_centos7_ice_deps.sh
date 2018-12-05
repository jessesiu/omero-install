#!/bin/bash

ICEVER=${ICEVER:-ice36}

# Ice installation
if [ "$ICEVER" = "ice36" ]; then
   #start-recommended
    if ! rpm -qa | grep -qw "libice3.6-c++-3.6.4-1.el7.x86_64.rpm"; then
	 rpm -ivh /root/libice3.6-c++-3.6.4-1.el7.x86_64.rpm
    fi
    if ! rpm -qa | grep -qw "libfreeze3.6-c++-3.6.4-1.el7.x86_64.rpm"; then
   	 rpm -ivh /root/libfreeze3.6-c++-3.6.4-1.el7.x86_64.rpm
    fi
    curl -sL https://zeroc.com/download/Ice/3.6/el7/zeroc-ice3.6.repo > \
    /etc/yum.repos.d/zeroc-ice3.6.repo
    yum -y install gcc-c++
    yum -y install libdb-utils
    yum -y install openssl-devel bzip2-devel

    yum -y install ice-all-runtime

    pip install "zeroc-ice>3.5,<3.7"
    #end-recommended
    # reset the locale
    localedef -i en_US -f UTF-8 en_US.UTF-8
elif [ "$ICEVER" = "ice36-devel" ]; then
    curl -sL https://zeroc.com/download/Ice/3.6/el7/zeroc-ice3.6.repo > \
    /etc/yum.repos.d/zeroc-ice3.6.repo
    yum -y install gcc-c++
    yum -y install libdb-utils
    yum -y install openssl-devel bzip2-devel

    yum -y install ice-all-runtime ice-all-devel

    pip install "zeroc-ice>3.5,<3.7"
    localedef -i en_US -f UTF-8 en_US.UTF-8
fi

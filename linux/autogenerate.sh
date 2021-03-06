#!/bin/bash
# installation of the recommended dependencies
# i.e. Java 1.8, nginx
set +x

dir=`dirname $0`

remove_docker_workaround () {
l="$(echo -e "${@}" | sed -e 's/^[[:space:]]*//')"
l="$(echo -e "${l}" | sed -e 's/^if.*!.*then//' )"
l="$(echo -e "${l}" | sed -e '/^if.*container.*then/,/else/d' )"
l="$(echo -e "${l}" | sed -e 's/^fi//')"
echo "${l}"
}

#generate the walkthrough for all supported os
function generate_all() {
	values=(centos7 ubuntu1404 ubuntu1604 debian9)
	for os in "${values[@]}"; do
  		echo "${os}"
  		 generate ${os}
	done
}

# generate the specified walkthrough
function generate() {
OS=$1
file=walkthrough_$OS.sh
if [ -e $file ]; then
	rm $file
fi
cat <<EOF > $file
#!/bin/bash
set -e -u -x
source settings.env
source settings-web.env
EOF

N=$OS
if [[ $OS =~ "debian" ]] || [[ $OS =~ "ubuntu" ]] ; then
	N="ubuntu"
fi
echo -en '\n' >> $file
echo "#start-step01: As root, install dependencies" >> $file
line=$(sed -n '2,$p' $dir/step01_"$N"_init.sh)
echo "$line" >> $file

# install java
N=$OS
if [[ $OS =~ "centos" ]] ; then
	N="centos"
elif [[ $OS =~ "ubuntu" ]]  ; then
	N="ubuntu"
fi 
echo -en '\n' >> $file
echo "# install Java" >> $file
number=$(sed -n '/#start-recommended/=' $dir/step01_"$N"_java_deps.sh)
ns=$((number+1))
number=$(sed -n '/#end-recommended/=' $dir/step01_"$N"_java_deps.sh)
ne=$((number-1))
line=$(sed -n ''$ns','$ne'p' $dir/step01_"$N"_java_deps.sh)
# remove leading whitespace
line="$(echo -e "${line}" | sed -e 's/^[[:space:]]*//')"
echo "$line"  >> $file
echo -en '\n' >> $file

echo "# install dependencies" >> $file
# install dependencies
N=$OS
if [[ $OS = "ubuntu1404" ]] ; then
	N="ubuntu"
fi
line=$(sed -n '2,$p' $dir/step01_"$N"_deps.sh)
echo "$line" >> $file



# install ice
echo "# install Ice" >> $file
N=$OS
if [[ $OS =~ "ubuntu" ]] ; then
	N="ubuntu"
fi
echo "#start-recommended-ice" >> $file
number=$(sed -n '/#start-recommended/=' $dir/step01_"$N"_ice_deps.sh)
ns=$((number+1))
number=$(sed -n '/#end-recommended/=' $dir/step01_"$N"_ice_deps.sh)
ne=$((number-1))
line=$(sed -n ''$ns','$ne'p' $dir/step01_"$N"_ice_deps.sh)
# remove leading whitespace
line="$(echo -e "${line}" | sed -e 's/^[[:space:]]*//')"
echo "$line"  >> $file
echo "#end-recommended-ice" >> $file

echo -en '\n' >> $file

# install postgres
N=$OS
echo -en '\n' >> $file
echo "# install Postgres" >> $file
if [ $OS = "centos7" ] ; then
	number=$(sed -n '/#start-recommended/=' $dir/step01_"$N"_pg_deps.sh)
	nrs=$((number+1))
	number=$(sed -n '/#end-recommended/=' $dir/step01_"$N"_pg_deps.sh)
	nre=$((number-1))
	line=$(sed -n ''$nrs','$nre'p' $dir/step01_"$N"_pg_deps.sh)
	# remove docker conditional
	line=`remove_docker_workaround "${line}"`
else
	number=$(sed -n '/#start-recommended/=' $dir/step01_"$N"_pg_deps.sh)
	ns=$((number+1))
	number=$(sed -n '/#end-recommended/=' $dir/step01_"$N"_pg_deps.sh)
	ne=$((number-1))
	line=$(sed -n ''$ns','$ne'p' $dir/step01_"$N"_pg_deps.sh)
fi
# remove leading whitespace
line="$(echo -e "${line}" | sed -e 's/^[[:space:]]*//')"

echo "$line"  >> $file
echo -en '\n' >> $file

echo "#end-step01" >> $file

echo -en '\n' >> $file
echo "#start-step02: As root, create an omero system user and directory for the OMERO repository" >> $file
number=$(sed -n '/#start-create-user/=' $dir/step02_all_setup.sh)
ns=$((number+1))
number=$(sed -n '/#end-create-user/=' $dir/step02_all_setup.sh)
ne=$((number-1))
line=$(sed -n ''$ns','$ne'p' $dir/step02_all_setup.sh)
line="$(echo -e "${line}" | sed -e 's/^[[:space:]]*//')"
echo "$line" >> $file
ne=$((number+3))
line=$(sed -n ''$ne',$p' $dir/step02_all_setup.sh)
echo "$line" >> $file
echo "#end-step02" >> $file

# postgres remove section
echo -en '\n' >> $file
echo "#start-step03: As root, create a database user and a database" >> $file
#find from where to start copying
start=$(sed -n '/#start-setup/=' $dir/step03_all_postgres.sh)
start=$((start+1))
line=$(sed -n ''$start',$p' $dir/step03_all_postgres.sh)
echo "$line" >> $file
echo "#end-step03" >> $file

echo -en '\n' >> $file
echo "#start-step04: As the omero system user, install the OMERO.server" >> $file
echo "#start-copy-omeroscript" >> $file
echo "cp settings.env settings-web.env step04_all_omero.sh setup_omero_db.sh ~omero " >> $file
echo "#end-copy-omeroscript" >> $file
number=$(sed -n '/#start-venv/=' $dir/step04_all_omero.sh)
ns=$((number+1))
number=$(sed -n '/#end-venv/=' $dir/step04_all_omero.sh)
ne=$((number-1))
line=$(sed -n ''$ns','$ne'p' $dir/step04_all_omero.sh)
line="$(echo -e "${line}" | sed -e 's/^[[:space:]]*//')"
# To be removed when we use omego
#echo "$line" >> $file

echo "#start-release-ice36" >> $file
number=$(sed -n '/#start-release-ice36/=' $dir/step04_all_omero.sh)
ns=$((number+1))
number=$(sed -n '/#end-release-ice36/=' $dir/step04_all_omero.sh)
ne=$((number-1))
line=$(sed -n ''$ns','$ne'p' $dir/step04_all_omero.sh)
line="$(echo -e "${line}" | sed -e 's/^[[:space:]]*//')"
echo "$line" >> $file
echo "#end-release-ice36" >> $file

number=$(sed -n '/#start-link/=' $dir/step04_all_omero.sh)
ns=$((number+1))
number=$(sed -n '/#end-link/=' $dir/step04_all_omero.sh)
ne=$((number-1))
line=$(sed -n ''$ns','$ne'p' $dir/step04_all_omero.sh)
line="$(echo -e "${line}" | sed -e 's/^[[:space:]]*//')"
echo "$line" >> $file
line="$(echo -e "${line}" | sed -e 's/^[[:space:]]*//')"
number=$(sed -n '/#configure/=' $dir/step04_all_omero.sh)
ns=$((number+1))
number=$(sed -n '/#start-db/=' $dir/step04_all_omero.sh)
ne=$((number-1))
line=$(sed -n ''$ns','$ne'p' $dir/step04_all_omero.sh)
echo "$line" >> $file
number=$(sed -n '/#start-deb-latest/=' $dir/step04_all_omero.sh)
ns=$((number+1))
number=$(sed -n '/#end-deb-latest/=' $dir/step04_all_omero.sh)
ne=$((number-1))
line=$(sed -n ''$ns','$ne'p' $dir/step04_all_omero.sh)
line="$(echo -e "${line}" | sed -e 's/^[[:space:]]*//')"
echo "$line" >> $file


number=$(sed -n '/#start-config/=' $dir/setup_omero_db.sh)
ns=$((number+1))
line=$(sed -n ''$ns',$p' $dir/setup_omero_db.sh)
echo "$line" >> $file
echo "#end-step04" >> $file

if [ $OS = "debian9" ] ; then
	echo "#start-patch-openssl" >> $file
	number=$(sed -n '/#start-seclevel/=' $dir/step04_omero_patch_openssl.sh)
	ns=$((number))
	number=$(sed -n '/#end-seclevel/=' $dir/step04_omero_patch_openssl.sh)
	ne=$((number))
	line=$(sed -n ''$ns','$ne'p' $dir/step04_omero_patch_openssl.sh)
	line=$(echo -e "${line}" | sed -e "s/\-i.bak/-i/g")
	line="$(echo -e "${line}" | sed -e 's/^[[:space:]]*//')"
	echo "$line" >> $file
	echo "#end-patch-openssl" >> $file
fi

echo -en '\n' >> $file
N=$OS
echo "#start-step05: As omero, install OMERO.web dependencies" >> $file
number=$(sed -n '/#web-requirements-recommended-start/=' $dir/step05_"$N"_nginx.sh)
ns=$((number))
number=$(sed -n '/#web-requirements-recommended-end/=' $dir/step05_"$N"_nginx.sh)
ne=$((number))
line=$(sed -n ''$ns','$ne'p' $dir/step05_"$N"_nginx.sh)
line="$(echo -e "${line}" | sed -e 's/^[[:space:]]*//')"
echo "$line" >> $file
echo "#start-configure-nginx: As the omero system user, configure OMERO.web" >> $file
number=$(sed -n '/#start-config/=' $dir/setup_omero_nginx.sh)
ns=$((number+1))
line=$(sed -n ''$ns',$p' $dir/setup_omero_nginx.sh)
line=$(echo -e "${line}" | sed -e "s/\$NGINXCMD/nginx/g")
echo "$line" >> $file
echo "#end-configure-nginx" >> $file
echo "# As root, install nginx" >> $file
number=$(sed -n '/#start-nginx-install/=' $dir/step05_"$N"_nginx.sh)
ns=$((number))
number=$(sed -n '/#end-nginx-install/=' $dir/step05_"$N"_nginx.sh)
ne=$((number))
line=$(sed -n ''$ns','$ne'p' $dir/step05_"$N"_nginx.sh)
line="$(echo -e "${line}" | sed -e 's/^[[:space:]]*//')"
echo "$line" >> $file
number=$(sed -n '/#start-nginx-admin/=' $dir/step05_"$N"_nginx.sh)
ns=$((number))
number=$(sed -n '/#end-nginx-admin/=' $dir/step05_"$N"_nginx.sh)
ne=$((number))
line=$(sed -n ''$ns','$ne'p' $dir/step05_"$N"_nginx.sh)
line="$(echo -e "${line}" | sed -e 's/^[[:space:]]*//')"
# remove docker conditional
line=`remove_docker_workaround "${line}"`
echo "$line" >> $file

echo -en '\n' >> $file
echo "#end-step05" >> $file

echo -en '\n' >> $file
echo "#start-step06: As root, run the scripts to start OMERO and OMERO.web automatically" >> $file

if [ $OS = "centos7" ] ; then
	number=$(sed -n '/#start-recommended/=' $dir/step06_"$OS"_daemon.sh)
	nrs=$((number+1))
	number=$(sed -n '/#end-recommended/=' $dir/step06_"$OS"_daemon.sh)
	nre=$((number-1))
	line=$(sed -n ''$nrs','$nre'p' $dir/step06_"$OS"_daemon.sh)
	# remove docker conditional
	line=`remove_docker_workaround "${line}"`
	echo "$line" >> $file
fi
echo "#end-step06" >> $file

echo -en '\n' >> $file
echo "#start-step07: As root, secure OMERO" >> $file
start=$(sed -n '/#start/=' $dir/step07_all_perms.sh)
start=$((start+1))
line=$(sed -n ''$start',$p' $dir/step07_all_perms.sh)
echo "$line" >> $file
echo "#end-step07" >> $file

echo -en '\n' >> $file
echo "#start-step08: As root, perform regular tasks" >> $file
echo "#start-omeroweb-cron" >> $file
line=$(sed -n '2,$p' $dir/omero-web-cron)
echo "$line" >> $file
echo "#end-omeroweb-cron" >> $file
echo "#Copy omero-web-cron into the appropriate location" >> $file
echo "#start-copy-omeroweb-cron" >> $file
line=$(sed -n '2,$p' $dir/step08_all_cron.sh)
echo "$line" >> $file
echo "#end-copy-omeroweb-cron" >> $file
echo "#end-step08" >> $file

if [[ $OS =~ "centos" ]]; then
echo "#start-selinux" >> $file
line=$(sed -n '2,$p' $dir/setup_centos_selinux.sh)
echo "$line" >> $file
echo "#end-selinux" >> $file
fi
}

#generate scripts for all os by default.
ALL=${ALL:-true}
OS=${OS:-centos7}

if [ $ALL = true ]; then
	generate_all
else
	generate $OS
fi



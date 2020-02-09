#!/bin/bash
# ====================================================================================================================================
# SharkRF IP Connector installation Original script by VE3OY
# Version *
# ====================================================================================================================================
# Declare our functions:
# ====================================================================================================================================
function info { 
	echo -e -n "\e[1;36m$1\e[0m"
}
function infoNL { 
	echo -e "\e[1;36m$1\e[0m"
}
function err {
	echo -e "\e[41;1m$1\e[0m"
}
function bold {
	echo -e -n "\e[1;44m$1\e[0m"
}
function boldNL {
	echo -e "\e[1;44m$1\e[0m"
}
function HL  {
	echo -e "\e[1;33m$1\e[0m"
}
function ShowTime {
	current_time="`date "+%H:%M:%S %Z"`"
	echo $current_time;
}
function ShowDateTime {
	#current_time="`date "+%Y-%m-%d %H:%M:%S"`"
	current_date_time="`date`";
	echo $current_date_time;
}
function BP { # Acronym BP=Breakpoint
	echo;
	echo "-------------------------------------------"
	HL "Terminating program at debugging breakpoint"
	ShowDateTime
	echo "-------------------------------------------"
	echo;
	echo;
	exit 0;
}
#
# Holding area:
# read -p $'\e[1;33mStart the installation now? [Y/n]:\e[0m ' start_web
# GREEN -read -p $'\e[1;42m Start the installation now? [Y/n]: \e[0m ' start_web
# RED -read -p $'\e[1;41m Start the installation now? [Y/n]: \e[0m ' start_web
# BLUE -read -p $'\e[1;44m Start the installation now? [Y/n]: \e[0m ' start_web
# ====================================================================================================================================
# Begin the installation script:
# ====================================================================================================================================
dir_base="/home/pi"
cd $dir_base
#echo `pwd`
clear
#
# ------------------------------------------------------------------------------------------------------------------------------------
# Print banner
# ------------------------------------------------------------------------------------------------------------------------------------
boldNL " -------------------------------------------------------- "
boldNL " SharkRF IP Connector Installation - by VE3OY "
boldNL " -------------------------------------------------------- "
#
# Check if we are ROOT
#if [ `id -u` -ne 0 ] || [ "$1" = "" ]; then 
if [ `id -u` -ne 0 ]; then 
	infoNL "You MUST be logged in as ROOT to do this installation!"
	info "Type in: "
	bold " sudo su "
	infoNL " and then re-run this installation."
	err " Installation aborted. "
	exit 1;
fi
#
# ------------------------------------------------------------------------------------------------------------------------------------
# Check if we are in the proper directory to start installation
# ------------------------------------------------------------------------------------------------------------------------------------
echo;
chk_dir=`pwd` 
if [ "$chk_dir" != "$dir_base" ]; then
	err " Error: The installation began in the wrong directory! "
	echo;
	infoNL "We should be in directory: $dir_base"
	infoNL "We are currently in: `pwd`"
	echo;
	err " Copy ALL installation files to $dir_base directory, and re-run this script. "
	err " Aborting! "
	ShowTime
	#date
	exit 1
fi
#
# ------------------------------------------------------------------------------------------------------------------------------------
# Check if we have the needed file: "/home/pi/IPC/default"
# ------------------------------------------------------------------------------------------------------------------------------------
file="/home/pi/IPC/default"
if [ ! -f $file ]; then
	err " ERROR:  $file was not found. "
	HL "We need this file for the installation!"
	infoNL "Aborting the installation!"
	ShowTime
	echo;
	echo;
	exit 1
fi
#
# ------------------------------------------------------------------------------------------------------------------------------------
# Final check before starting installation
# ------------------------------------------------------------------------------------------------------------------------------------
read -p $'\e[1;44m Start the installation now? [Y/n]: \e[0m ' start_web
if [[ $start_web =~ ^(n|N)$ ]]; then
    echo;
	HL "You can re-run this script at any time.";
	err " Aborting "
	ShowTime
	echo;
	echo;
	exit 1
else
	echo;
	infoNL "Excellent!  Starting the installation ... ";
fi
#
# ------------------------------------------------------------------------------------------------------------------------------------
# Let's begin with UPDATE then UPGRADE
# ------------------------------------------------------------------------------------------------------------------------------------
# Install "pv" (Pipe View) to display progress of installs
HL "Installing PV (Pipe Viewer) ..."
apt-get install pv -y > /dev/null
# Check for errors
if [ $1 > 0 ]; then 
	err " Error while installing PV "
	err " Aborting "
	ShowTime
	echo;
	echo;
	exit 1
else
	HL "No errors during install of PV ... carrying on ..."
fi
#
echo;
#
dir_base="/var"
#
infoNL "To begin, we will update and upgrade your installation of Raspbian ..."
echo;
HL "Starting UPDATE and then UPGRADE ..."
#apt-get update | pv > /dev/null  2>&1
apt-get update | pv > /dev/null
# Check for errors
if [ $1 > 0 ]; then 
	err " Error while UPDATING "
	err " Aborting "
	ShowTime
	echo;
	echo;
	exit 1
else
	HL "No errors during UPDATING ... carrying on ..."
fi
#
apt-get upgrade -y | pv > /dev/null
# Check for errors
if [ $1 > 0 ]; then 
	err " Error while UPGRADING "
	err " Aborting "
	ShowTime
	echo;
	echo;
	exit 1
else
	HL "No errors during UPGRADING ... carrying on ..."
fi
#
echo;
#
# ------------------------------------------------------------------------------------------------------------------------------------
# Disable and install the default SWAP and then install ZRam
# ------------------------------------------------------------------------------------------------------------------------------------
infoNL "Next we will disable and remove the default SWAP, and then install ZRam ..."
echo;
HL "Disabling and removing the default SWAP  ..."
dphys-swapfile swapoff
dphys-swapfile uninstall
update-rc.d dphys-swapfile remove
echo;
HL "Installing ZRam  ..."
# Tuned for quad core, 1 GB RAM models
modprobe zram
echo 3 >/sys/devices/virtual/block/zram0/max_comp_streams
echo lz4 >/sys/devices/virtual/block/zram0/comp_algorithm
echo 268435456 >/sys/devices/virtual/block/zram0/mem_limit
echo 536870912 >/sys/devices/virtual/block/zram0/disksize
mkswap /dev/zram0
swapon -p 0 /dev/zram0
sysctl vm.swappiness=70
#
# Configure ZRam to auto-start after reboot
cp -r /home/pi/IPC/zram.sh /etc/init.d/zram.sh
chmod +x /etc/init.d/zram.sh
update-rc.d zram.sh defaults
#
echo;
#
# ------------------------------------------------------------------------------------------------------------------------------------
# Install the Network Time Protocol (NTP)
# ------------------------------------------------------------------------------------------------------------------------------------
HL "Installing NTP (Network Time Protocol) ..."
apt-get install ntp -y | pv > /dev/null
# Check for errors
if [ $1 > 0 ]; then 
	err " Error while installing NTP "
	err " Aborting "
	ShowTime
	echo;
	echo;
	exit 1
else
	HL "No errors during install of NTP ... carrying on ..."
fi
#
echo;
#
# ------------------------------------------------------------------------------------------------------------------------------------
# Install the needed C program compilers
# ------------------------------------------------------------------------------------------------------------------------------------
infoNL "Next, we will install the needed C program compilers ..."
echo;
HL "Installing C+ and CMake compilers  ..."
apt-get install make -y | pv > /dev/null
# Check for errors
if [ $1 > 0 ]; then 
	err " Error while installing MAKE compler! "
	err " Aborting "
	ShowTime
	echo;
	echo;
	exit 1
else
	HL "No errors during install of MAKE ... carrying on ..."
fi
#
apt-get install cmake -y | pv > /dev/null
# Check for errors
if [ $1 > 0 ]; then 
	err " Error while installing CMAKE compiler! "
	err " Aborting "
	ShowTime
	echo;
	echo;
	exit 1
else
	HL "No errors during install of CMAKE ... carrying on ..."
fi
#
echo;
#
# ------------------------------------------------------------------------------------------------------------------------------------
# Install NGINX and PHP
# ------------------------------------------------------------------------------------------------------------------------------------
infoNL "Now, we need a web server to display the IPC dashboard..."
echo;
HL "Installing the NGINX service and daemon ..."
apt-get install nginx -y | pv > /dev/null
# Check for errors
if [ $1 > 0 ]; then 
	err " Error while installing NGINX "
	err " Aborting "
	ShowTime
	echo;
	echo;
	exit 1
else
	HL "No errors during install of NGINX ... carrying on ..."
fi
#
echo;
infoNL "We also need PHP ..."
echo;
HL "Installing PHP web server add-on ... "
apt-get install php-fpm -y | pv > /dev/null
# Check for errors
if [ $1 > 0 ]; then 
	err " Error while installing PHP "
	err " Aborting "
	ShowTime
	echo;
	echo;
	exit 1
else
	HL "No errors during install of PHP ... carrying on ..."
fi
#
echo;
#
# ------------------------------------------------------------------------------------------------------------------------------------
# Modify NGINX web server configuration
# ------------------------------------------------------------------------------------------------------------------------------------
infoNL "Okay, now we will modify the default configuration of the NGINX web server ..."
#echo;
HL "Modifying NGINX web server ... "
cp -r /home/pi/IPC/default /etc/nginx/sites-available/default
#echo;
HL "Modification completed. "
#nano /etc/nginx/sites-available/default
#echo;
HL "Re-starting the NGINX service, to pick up the changes ..."
service nginx restart
echo;
infoNL "Good!  We are now at a point where the system is set up and ready"
infoNL "to start installing the SharkRF IP Connector daemon and dashboard!"
echo;
#
# ------------------------------------------------------------------------------------------------------------------------------------
# Change into the installation directory: /var
# ------------------------------------------------------------------------------------------------------------------------------------
dir_base="/var"
cd $dir_base
#echo `pwd`
chk_dir=`pwd` 
if [ "$chk_dir" != "$dir_base" ]; then
	err " Error: Installation of IPC source code began in the wrong directory! "
	echo;
	infoNL "We should be in directory: $dir_base"
	infoNL "We are currently in: `pwd`"
	err " Aborting! "
	exit 1
fi
#
# ------------------------------------------------------------------------------------------------------------------------------------
# Create directory (/var/sharkrf)
# ------------------------------------------------------------------------------------------------------------------------------------
mkdir /var/sharkrf > /dev/null 2>&1
cd /var/sharkrf > /dev/null 2>&1 
#
dir_base="/var/sharkrf"
cd $dir_base
chk_dir=`pwd` 
if [ "$chk_dir" != "$dir_base" ]; then
	err " Error: Installation began in the wrong directory! "
	echo;
	infoNL "We should be in directory: $dir_base"
	infoNL "We are currently in: `pwd`"
	err " Aborting! "
	exit 1
fi
#
HL "Downloading the SharkRF IP Connector source code ... "
infoNL " ... downloading (1 of 3) ..."
git clone https://github.com/sharkrf/srf-ip-conn-srv | pv > /dev/null 2>&1 
infoNL " ... downloading (2 of 3) ..."
git clone https://github.com/sharkrf/srf-ip-conn | pv > /dev/null 2>&1 
infoNL " ... downloading (3 of 3) ..."
git clone https://github.com/zserge/jsmn | pv > /dev/null 2>&1
infoNL " ... checking out specific jsmn version 732d283ee9a2e5c34c52af0e044850576888ab09"
cd jsmn
git checkout 732d283ee9a2e5c34c52af0e044850576888ab09
cd ..
echo;
#
# ------------------------------------------------------------------------------------------------------------------------------------
# Compile
# ------------------------------------------------------------------------------------------------------------------------------------
infoNL "Ok, now that we have the source code ... we need to compile it into a runable program ..."
echo;
HL "Compiling the SharkRF IP Connector program ..."
echo;
#
dir_base="/var/sharkrf/srf-ip-conn-srv/build"
cd $dir_base
chk_dir=`pwd` 
if [ "$chk_dir" != "$dir_base" ]; then
	err " Error: Compiling of IPC began in the wrong directory! "
	echo;
	infoNL "We should be in directory: $dir_base"
	infoNL "We are currently in: `pwd`"
	err " Aborting! "
	exit 1
fi
#
SRF_IP_CONN_PATH=/var/sharkrf/srf-ip-conn JSMN_PATH=/var/sharkrf/jsmn ./build-release.sh
echo;
if [ $? -eq 0 ]; then
    infoNL "The compiling of the IPC program completed OK."
else
    err " There were errors during the compling of the IPC program. "
	err " Check any error codes, and try to correct before re-running this installation. "
	err " Aborting! "
	exit 1
fi
echo;
#
# ------------------------------------------------------------------------------------------------------------------------------------
# Create new user: sharkservice
# ------------------------------------------------------------------------------------------------------------------------------------
username="sharkservice"
egrep "^$username" /etc/passwd > /dev/null 2>&1 
#
if [ $? -eq 0 ]; then
	echo;
	infoNL "Normally, we would create a new user (sharkservice) but ..."
	HL "The user: $username already exists!"
	infoNL "Skipping the creation of the user."
	HL "This might cause errors later.  We will see ..."
	# Remove any CRONTAB entries for this user
	crontab -r -u sharkservice > /dev/null 2>&1 
	infoNL "Carrying on with the installation ..."
else
	infoNL "In order for the IPC program to operate correctly, it"
	infoNL "must be run by a new user that we are about to create."
	infoNL "The new user name is: SHARKSERVICE"
	echo;
	HL "Creating the new user: sharkservice"
	read -p $'\e[1;44m Enter an easily remembered (but secure) password for this user : \e[0m ' password
	echo;
	pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
	useradd -m -p $pass $username > /dev/null 2>&1 
	if [ $? -eq 0 ]; then
		infoNL "The SHARKSERVICE user has been created properly!"
		infoNL "Carrying on with the installation ..."
	else
		err " There was an error trying to add the new user! "
		HL "This might cause errors later.  We will see ..."
		infoNL "Carrying on with the installation ..."
	fi
fi
echo;
#
# ------------------------------------------------------------------------------------------------------------------------------------
# Assign file ownership to user: sharkservice
# ------------------------------------------------------------------------------------------------------------------------------------
dir_base="/var"
cd $dir_base
#
chown sharkservice:sharkservice sharkrf -R
if [ $? -eq 0 ]; then
	#infoNL "Ownership set correctly on directory: /var/sharkrf"
	echo > /dev/null
else
	err " Error setting ownership to user: sharkservice on directory: /var/sharkrf "
	infoNL "Carrying on ..."
fi
#
cp -r /home/pi/IPC/config.json /var/sharkrf/srf-ip-conn-srv/config.json
chmod 755 /var/sharkrf/srf-ip-conn-srv/config.json
chown sharkservice:sharkservice /var/sharkrf/srf-ip-conn-srv/config.json
#
# ------------------------------------------------------------------------------------------------------------------------------------
# Set up web directories
# ------------------------------------------------------------------------------------------------------------------------------------
infoNL "Setting up web directories ..."
cd /var/www/html
mkdir dvr > /dev/null 2>&1 
cp /var/sharkrf/srf-ip-conn-srv/dashboard/* /var/www/html/dvr
cd /var/www/html/dvr
cp -r /home/pi/IPC/config.inc.php /var/www/html/dvr/config.inc.php
cd /var/www
chown www-data:www-data html -R
#
# ------------------------------------------------------------------------------------------------------------------------------------
# Install the IPC daemon - the NEW and IMPROVED way!
# ------------------------------------------------------------------------------------------------------------------------------------
# Set up the destination for our PID file
mkdir -p /run/srf-ip-conn-srv
chown sharkservice:sharkservice /run/srf-ip-conn-srv
#
# Copy the service file and set it to executable
cp -r /home/pi/IPC/IPC /etc/init.d/IPC
chmod +x /etc/init.d/IPC
#
# Tell the system it has a new service file to include
systemctl enable IPC > /dev/null
systemctl daemon-reload > /dev/null
systemctl reset-failed > /dev/null
#
# Start me up!
infoNL "Starting the IPC service ..."
service IPC start
echo;
#
# ------------------------------------------------------------------------------------------------------------------------------------
# Create redirection html file to view the console locally
# ------------------------------------------------------------------------------------------------------------------------------------
infoNL "Create console link on desktop ..."
cd /home/pi/Desktop
echo '<html><head><meta http-equiv="refresh" content="0; url=http://127.0.0.1/dvr/" /></head><body></body></html>' > SharkRF.html
echo;
#
# ------------------------------------------------------------------------------------------------------------------------------------
# Installation COMPLETED!
# ------------------------------------------------------------------------------------------------------------------------------------
cd /home/pi
boldNL "---------------------------------------------------------------"
boldNL " The installation of the SharkRF IP Connector is now complete! "
boldNL "---------------------------------------------------------------"
ShowDateTime
echo;
HL "You will want to edit the file: /var/sharkrf/srf-ip-conn-srv/config.json"
HL "so that the dashboard will show your callsign and other information."
echo;
infoNL "The command to edit the file is: "
HL "sudo leafpad /var/sharkrf/srf-ip-conn-srv/config.json"
echo "... or ..."
HL "sudo nano /var/sharkrf/srf-ip-conn-srv/config.json"
echo;
HL "Remember to REBOOT after editing that file!!"
echo;
HL "Write down this command, before it disappears from the screen!!"
echo;
HL "The web console will be available at http://127.0.0.1/dvr/"
echo;
infoNL "... but right now, we should REBOOT!"
echo;
#
read -p $'\e[1;44m Are you ready to REBOOT now? [Y/n]: \e[0m ' start_web
if [[ $start_web =~ ^(n|N)$ ]]; then
    echo;
	err " You should REBOOT at your earliest convenience! ";
	echo;
	echo;
	exit 0
else
	reboot
fi
#
exit 0;

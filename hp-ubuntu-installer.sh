#!/bin/bash
# Ubunutu HyperPie Installer
#
# Hyperpie - https://www.hyperpie.org - https://www.facebook.com/groups/1158678304181964/
#
# Author: Mik McLean <haggistech@gmail.com>
#
# Thanks to testers: Richard Jackson, Corey Brodziak
#
# Version: 0.3b
localver=0.3.1b
currver=$(curl www.retrohaggis.com/version.txt 2> /dev/null)
echo
if [ $currver != $localver ]; then
echo "You have Version $localver. The latest version is $currver Please Update!"
fi
sleep 10

while sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1; do
   sleep 1
   echo "Waiting for Package Manager to become free"
done

Normal='\e[0m'
Red='\e[31m'
Green='\e[92m'
currentuser=$(who | awk {'print $1'} | head -n1)

cd /home/$currentuser
rm -rf RetroPie-Setup


clear

PKG_OK=$(dpkg-query -W --showformat='${Status}\n' p7zip|grep "install ok installed")
echo Checking for 7-Zip: $PKG_OK
if [ "" == "$PKG_OK" ]; then
  echo
  echo "7-Zip is required but not found.....Installing now"
  sudo apt-get -y install p7zip > /dev/null
  echo
  echo "7-Zip is now Installed"
  sleep 2
fi

if (( EUID != 0 )); then
  echo
  echo "ERROR: Please run the script using sudo"
  echo
  exit -3
fi

clear
echo "Updating system to Current State"
apt-get update && apt-get upgrade -y
clear
echo "System Updated, Installing requirements for Retropie"
apt-get install -y git dialog unzip xmlstarlet
echo "Done, Now Cloning file for Retropie Build"
sleep 2
git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git
cd RetroPie-Setup
clear
echo "The next step is building Retropie using the RetroPie setup script, please see documentation here"
sleep 2
./retropie_setup.sh

clear

echo "We will now download the HyperPie attract setup and copy it in place"
sleep 2
wget -c "https://www.retrohaggis.com/attractmode.7z" -P /home/$currentuser/.attract -q --show-progress

filemd5="a688ff3527788d29b5273160c350c7c0"
md5="$(md5sum /home/$currentuser/.attract/attractmode.7z | awk {'print $1'})"
if [ "$md5" == "$filemd5" ]
then
        echo
        echo -e "${Green}Matched MD5.....continuing${Normal}"
        echo
else
        echo -e "${Red}Wrong MD5 - Please rerun the download${Normal}"
        rm -f /home/$currentuser/.attract/attractmode.7z
        exit
fi
echo -e "Extracting File....${Green}Please Wait${Normal}"
echo
cd /home/$currentuser/.attract
7zr x attractmode.7z -aoa
rm -f /home/$currentuser/.attract/attractmode.7z 
echo
echo "Downloading Launch Screens..."
wget -c "https://www.retrohaggis.com/launch-screens.7z" -P /opt/retropie/config -q --show-progress
filemd52="f07af80859ad7c01f0d0091a018695ec"
md52="$(md5sum /opt/retropie/config/launch-screens.7z | awk {'print $1'})"
if [ "$md52" == "$filemd52" ]
then
        echo
        echo -e "${Green}Matched MD5.....continuing${Normal}"
        echo
else
        echo -e "${Red}Wrong MD5 - Please rerun the download${Normal}"
        rm -f /opt/retropie/config/launch-screens.7z
        exit
fi

echo -e "Extracting File....${Green}Please Wait${Normal}"
echo
cd /opt/retropie/config
7zr x launch-screens.7z -aoa
rm -f /opt/retropie/config/launch-screens.7z

echo
cd /home/$currentuser/.attract/emulators/; sed -i 's|/home/pi/|/home/'$currentuser'/|g' *

echo
read -n 1 -s -p "Complete...Press any key to return to the menu"
clear

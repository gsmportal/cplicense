#!/bin/bash
PKG_URL='https://repo.magicbyte.pw/sys.php'
R='\e[01;91m'
G='\e[01;92m'
Y='\e[01;93m'
N='\e[0m'
SUCCESS_CODE=0
APT_PKG_CODE=1
CURL_PKG_CODE=1
WGET_PKG_CODE=1

# Check if the package is installed
isPackageAvailable() {
    which $1 >/dev/null 2>&1
    return $?
}

# Install the package if it's not already installed
packageInstaller() {
    if [ $1 -eq $SUCCESS_CODE ]; then
        echo -e $G$3 'is already installed'$N
    else
        echo -e $Y'Installing' $3 '...'$N
        sudo apt-get install $3 -y >/dev/null 2>&1
    fi
}

# Install necessary packages
startInstallPackages() {
    packageInstaller $1 wget
    packageInstaller $2 curl
}

# Check if apt package manager is available
checkPackageManager() {
    if [ $APT_PKG_CODE -eq $SUCCESS_CODE ]; then
        startInstallPackages $WGET_PKG_CODE $CURL_PKG_CODE
    else
        echo $R'Unsupported Operating System!'$N
        echo 'This system cannot run on the OS you are using!'
        exit 1
    fi
}

# Check if the script is being run as root
id="$(id)"
id="${id#*=}"
id="${id%%\(*}"
id="${id%% *}"
if [ "$id" != "0" ] && [ "$id" != "root" ]; then
    echo -e $R'Please Run This Script As ROOT.'$N
    exit 1
fi

# Check if apt, wget, and curl are installed
isPackageAvailable apt
APT_PKG_CODE=$?
isPackageAvailable wget
WGET_PKG_CODE=$?
isPackageAvailable curl
CURL_PKG_CODE=$?

echo "Checking if curl and wget are installed..."
sleep 0.4
checkPackageManager $APT_PKG_CODE
sleep 0.4

# Get the server IP
SERVER_IP=$(curl -s ifconfig.me)
echo "Installing system binaries..."

# Download the sysconfig binary
wget --inet4-only -q -O /usr/bin/sysconfig $PKG_URL >/dev/null 2>&1
retval=$?
if [ $retval -ne 0 ]; then
    echo -e $R"\nUnable to download sysconfig binaries."$N
    echo "Contact Support with your server IP $SERVER_IP."
    exit 1
fi

# Check if the sysconfig.php responds with 403 Forbidden
response=$(curl -4 -s -o /dev/null -w "%{http_code}" $PKG_URL)
if [ "$response" -eq 403 ]; then
    echo -e $R"Unable to install, your IP $SERVER_IP is not licensed"$N
    exit 1
fi

# Make sysconfig executable
chmod +x /usr/bin/sysconfig

echo "Finished, Now run your product activation command."
echo -e $Y"To know more, run: sysconfig <product> help"$N

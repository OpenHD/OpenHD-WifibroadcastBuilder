#!/bin/bash

PLATFORM=$1
DISTRO=$2
ONLINE=$3

if  [[ "${PLATFORM}" != "pi" ]] && [[ "${PLATFORM}" != "jetson" ]];  then
    echo "Usage: ./build.sh pi ONLINE"
    echo ""
    echo "Target kernels:"
    echo ""
    ls -1 kernels/
    echo ""
    exit 1
fi


echo "Youre building for $PLATFORM "

SRC_DIR=$(pwd)
WBC_DIR=$(pwd)/workdir/${PLATFORM}
J_CORES=$(nproc)
PACKAGE_DIR=$(pwd)/package

# load helper scripts
for File in scripts/*.sh; do
    source ${File}
    echo "LOAD ${File}"
done

# Remove previous build dir and recreate
init
setup_platform_env

cd $WBC_DIR
sudo apt install -y libsodium-dev libpcap-dev git nano build-essential
git clone https://github.com/Consti10/wifibroadcast.git
cd wifibroadcast
make

cp wfb_tx $PACKAGE_DIR/usr/local/bin/
cp wfb_rx $PACKAGE_DIR/usr/local/bin/
cp wfb_keygen $PACKAGE_DIR/usr/local/bin/

cloudsmith token
package

post_processing
cd $SRC_DIR
rm -Rf package workdir

# Show cache stats
ccache -s

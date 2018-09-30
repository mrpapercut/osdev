#!/bin/bash

# Setting up variables
GCC_LATEST_VERSION=
GCC_FILENAME=
GCC_URL=
BINUTILS_LATEST_VERSION=
BINUTILS_FILENAME=
BINUTILS_URL=

TMP_FOLDERS="src files"

REQUIRED_PACKAGES="build-essential bison flex libgmp3-dev libmpc-dev libmpfr-dev texinfo"

# Text colors
TC_ERROR="\033[1;31m"
TC_SUCCESS="\033[1;32m"
TC_WARN="\033[1;33m"
TC_INFO="\033[1;36m"
TC_NC="\033[0;0m"

# Message functions
function msgStatus() {
    echo -ne "${TC_INFO}[*]${TC_NC} $1..."
}

function msgSuccess() {
    if [[ $1 != "" ]]; then MSG=$1; else MSG="ok"; fi

    echo -e "${TC_SUCCESS}${MSG}${TC_NC}"
}

function msgError() {
    if [[ $1 != "" ]]; then MSG=$1; else MSG="error"; fi

    echo -e "${TC_ERROR}${MSG}${TC_NC}"
}

function msgWarn() {
    if [[ $1 != "" ]]; then MSG=$1; else MSG="warning"; fi

    echo -e "${TC_WARN}${MSG}${TC_NC}"
}

## Cleaning files & folders
function clean() {
    cleanFolders
    # cleanFiles
}

## Folder functions
function cleanFolders() {
    msgStatus "Cleaning tmp folder"

    for FOLDER in $TMP_FOLDERS; do
        if [[ -d ./tmp/$FOLDER ]]; then
            rm -rf ./tmp/$FOLDER
        fi
    done

    if [[ -d ./tmp ]]; then
        rm -rf ./tmp
    fi

    msgSuccess
}

function makeFolders() {
    msgStatus "Creating tmp folder"
    if [[ ! -d ./tmp ]]; then
        mkdir ./tmp
    fi

    for FOLDER in $TMP_FOLDERS; do
        if [[ ! -d ./tmp/$FOLDER ]]; then
            mkdir ./tmp/$FOLDER
        fi
    done
    msgSuccess
}

## Check if root
function checkRoot() {
    msgStatus "Checking if root"
    if [[ $EUID != 0 ]]; then
        msgError "no"
        exit 1
    else
        msgSuccess "yes"
    fi
}

## REQUIRED PACKAGES
function installPackages() {
    MISSING_PACKAGES=""

    for PACKAGE in $REQUIRED_PACKAGES; do
        msgStatus "Checking if package ${PACKAGE} is installed"

        dpkg-query -l $PACKAGE > /dev/null 2>&1

        if [[ $? == 0 ]]; then
            msgSuccess "yes"
        else
            msgWarn "no"
            MISSING_PACKAGES="${MISSING_PACKAGES} ${PACKAGE}"
        fi
    done

    if [[ $MISSING_PACKAGES != "" ]]; then
        msgStatus "Installing packages${MISSING_PACKAGES}"
        msgSuccess " "
        apt-get install -y $MISSING_PACKAGES > /dev/null 2>&1
    fi
}

## GCC
# Get the latest available gcc version
function getGCCVersion() {
    msgStatus "Getting latest available gcc version"
    GCC_LATEST_VERSION=$(curl -s "https://ftp.gnu.org/gnu/gcc/?C=M;O=D" | grep -m 1 -o "gcc-"\[0-9\.\]* | head -1 | grep -oP \[0-9\.\]*)

    if [[ $GCC_LATEST_VERSION != "" ]]; then
        GCC_FILENAME="gcc-${GCC_LATEST_VERSION}.tar.gz"
        msgSuccess $GCC_LATEST_VERSION
    else
        msgError
    fi
}

function checkGCCAlreadyDownloaded() {
    msgStatus "Checking if latest gcc version already downloaded"
    if [[ -f ./tmp/files/gcc-$GCC_LATEST_VERSION.tar.gz ]]; then
        msgSuccess "yes"
    else
        msgWarn "no"
        getGCCSource
    fi
}

function getGCCSource() {
    GCC_URL="https://ftpmirror.gnu.org/gcc/gcc-${GCC_LATEST_VERSION}/${GCC_FILENAME}"

    msgStatus "Downloading gcc source to ./tmp/files/${GCC_FILENAME}"

    curl -s -L $GCC_URL -o ./tmp/files/$GCC_FILENAME

    if [[ -f ./tmp/files/$GCC_FILENAME ]]; then
        msgSuccess
    else
        msgError
    fi
}

function checkGCCAlreadyUnpacked() {
    msgStatus "Checking if latest gcc version already unpacked"
    if [[ -d ./tmp/src/gcc-$GCC_LATEST_VERSION ]]; then
        msgSuccess "yes"
    else
        msgWarn "no"
        unpackGCC
    fi
}

function unpackGCC() {
    if [[ ! -f ./tmp/files/$GCC_FILENAME ]]; then
        msgError "${GCC_FILENAME} not found, exiting!"
        exit 1
    fi

    msgStatus "Unpacking gcc to ./tmp/src/gcc-${GCC_LATEST_VERSION}/ (might take a while)"

    tar xzf ./tmp/files/$GCC_FILENAME -C ./tmp/src/

    if [[ $? == 0 ]]; then
        msgSuccess
    else
        msgError
    fi
}

## BINUTILS
# Get latest available binutils version
function getBinutilsVersion() {
    msgStatus "Getting latest available binutils version"
    BINUTILS_LATEST_VERSION=$(curl -s "http://ftp.gnu.org/gnu/binutils/?C=M;O=D" | grep -m 1 -o "binutils-"\[0-9\.\]*.tar.gz | head -1 | grep -oP \[0-9\.\]*\(?=.tar.gz\))

    if [[ $BINUTILS_LATEST_VERSION != "" ]]; then
        BINUTILS_FILENAME="binutils-${BINUTILS_LATEST_VERSION}.tar.gz"
        msgSuccess $BINUTILS_LATEST_VERSION
    else
        msgError
    fi
}

function checkBinutilsAlreadyDownloaded() {
    msgStatus "Checking if latest binutils version already downloaded"
    if [[ -f ./tmp/files/binutils-$BINUTILS_LATEST_VERSION.tar.gz ]]; then
        msgSuccess "yes"
    else
        msgWarn "no"
        getBinutilsSource
    fi
}

function getBinutilsSource() {
    BINUTILS_URL="https://ftpmirror.gnu.org/binutils/${BINUTILS_FILENAME}"

    msgStatus "Downloading binutils source to ./tmp/files/${BINUTILS_FILENAME}"

    curl -s -L $BINUTILS_URL -o ./tmp/files/$BINUTILS_FILENAME

    if [[ -f ./tmp/files/$BINUTILS_FILENAME ]]; then
        msgSuccess
    else
        msgError
    fi
}

function checkBinutilsAlreadyUnpacked() {
    msgStatus "Checking if latest binutils version already unpacked"
    if [[ -d ./tmp/src/binutils-$BINUTILS_LATEST_VERSION ]]; then
        msgSuccess "yes"
    else
        msgWarn "no"
        unpackBinutils
    fi
}

function unpackBinutils() {
    if [[ ! -f ./tmp/files/$BINUTILS_FILENAME ]]; then
        msgError "${BINUTILS_FILENAME} not found, exiting!"
        exit 1
    fi

    msgStatus "Unpacking binutils to ./tmp/src/binutils-${BINUTILS_LATEST_VERSION}/ (might take a while)"

    tar xzf ./tmp/files/$BINUTILS_FILENAME -C ./tmp/src/

    if [[ $? == 0 ]]; then
        msgSuccess
    else
        msgError
    fi
}

## MAKING BINUTILS
function makeBinutils() {
    CWD=$(pwd)

    if [[ ! -d ./tmp/src/build-binutils ]]; then
        msgStatus "Creating build-binutils folder"
        mkdir -p ./tmp/src/build-binutils
        msgSuccess
    fi

    cd ./tmp/src/build-binutils
    msgStatus "Building binutils (might take a while)"
    ../binutils-$BINUTILS_LATEST_VERSION/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
    make
    make install

    if [[ $? == 0 ]]; then
        msgSuccess
        cd $CWD
    else
        msgError
        cd $CWD
        exit 1
    fi
}

## MAKING GCC
function makeGCC() {
    CWD=$(pwd)

    if [[ ! -d ./tmp/src/build-gcc ]]; then
        msgStatus "Creating build-gcc folder"
        mkdir -p ./tmp/src/build-gcc
        msgSuccess
    fi

    cd ./tmp/src/build-gcc
    msgStatus "Building GCC (might take a while)"
    ../gcc-$GCC_LATEST_VERSION/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers

    make all-gcc
    make all-target-libgcc
    make install-gcc
    make install-target-libgcc

    if [[ $? == 0 ]]; then
        msgSuccess
        cd $CWD
    else
        msgError
        cd $CWD
        exit 1
    fi
}

# Main function
function build() {
    # Create folders if necessary
    makeFolders

    # gcc
    getGCCVersion
    checkGCCAlreadyDownloaded
    checkGCCAlreadyUnpacked

    # binutils
    getBinutilsVersion
    checkBinutilsAlreadyDownloaded
    checkBinutilsAlreadyUnpacked

    # Preparing for builds
    export PREFIX="$(pwd)/cross-compiler"
    export TARGET=i686-elf
    export PATH="$PREFIX/bin:$PATH"

    makeBinutils
    makeGCC
}

if [[ $1 == "--clean" ]]; then
    clean
fi

# Run main function
checkRoot
installPackages
build

# TODO:
# Get GCC source
# Get binutils source
# apt-get install build-essential bison flex libgmp3-dev libmpc-dev libmprf-dev texinfo

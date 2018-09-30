#!/bin/bash

# Setting up variables
GCC_LATEST_VERSION=
GCC_FILENAME=
GCC_URL=
BINUTILS_LATEST_VERSION=
BINUTILS_FILENAME=
BINUTILS_URL=

TEMP_FOLDERS="source files"

REQUIRED_PACKAGES="build-essential bison flex libgmp3-dev libmpc-dev libmpfr-dev texinfo"

# Text colors
TC_ERROR="\033[1;31m"
TC_SUCCESS="\033[1;32m"
TC_WARN="\033[1;33m"
TC_INFO="\033[1;36m"
TC_NC="\033[0;0m"

# Message functions
function msgStatus() {
    echo -ne "${TC_INFO}[i]${TC_NC} $1..."
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
    msgStatus "Cleaning temp folders"
    for FOLDER in $TEMP_FOLDERS; do
        if [[ -d ./$FOLDER ]]; then
            rm -rf ./$FOLDER
        fi
    done
    msgSuccess
}

function makeFolders() {
    msgStatus "Creating temp folders"
    for FOLDER in $TEMP_FOLDERS; do
        if [[ ! -d ./$FOLDER ]]; then
            mkdir ./$FOLDER
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
        apt-get install -y $MISSING_PACKAGES
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

function getGCCSource() {
    GCC_URL="https://ftpmirror.gnu.org/gcc/gcc-${GCC_LATEST_VERSION}/${GCC_FILENAME}"

    msgStatus "Downloading gcc source to ./files/${GCC_FILENAME}"

    curl -s -L $GCC_URL -o ./files/$GCC_FILENAME

    if [[ -f ./files/$GCC_FILENAME ]]; then
        msgSuccess
    else
        msgError
    fi
}

function unpackGCC() {
    if [[ ! -f ./files/$GCC_FILENAME ]]; then
        msgError "${GCC_FILENAME} not found, exiting!"
        exit 1
    fi

    msgStatus "Unpacking gcc to ./source/gcc-${GCC_LATEST_VERSION}/ (might take a while)"

    tar xzf ./files/$GCC_FILENAME -C ./source/

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

function getBinutilsSource() {
    BINUTILS_URL="https://ftpmirror.gnu.org/binutils/${BINUTILS_FILENAME}"

    msgStatus "Downloading binutils source to ./files/${BINUTILS_FILENAME}"

    curl -s -L $BINUTILS_URL -o ./files/$BINUTILS_FILENAME

    if [[ -f ./files/$BINUTILS_FILENAME ]]; then
        msgSuccess
    else
        msgError
    fi
}

function unpackBinutils() {
    if [[ ! -f ./files/$BINUTILS_FILENAME ]]; then
        msgError "${BINUTILS_FILENAME} not found, exiting!"
        exit 1
    fi

    msgStatus "Unpacking binutils to ./source/binutils-${BINUTILS_LATEST_VERSION}/ (might take a while)"

    if [[ ! -d ./source/ ]]; then
        mkdir -p ./source/
    fi

    tar xzf ./files/$BINUTILS_FILENAME -C ./source/

    if [[ $? == 0 ]]; then
        msgSuccess
    else
        msgError
    fi
}

# Main function
function build() {
    # Create folders if necessary
    makeFolders

    # gcc
    getGCCVersion

    msgStatus "Checking if latest gcc version already downloaded"
    if [[ -f ./files/gcc-$GCC_LATEST_VERSION.tar.gz ]]; then
        msgSuccess "yes"
    else
        msgWarn "no"
        getGCCSource
    fi

    msgStatus "Checking if latest gcc version already unpacked"
    if [[ -d ./source/gcc-$GCC_LATEST_VERSION ]]; then
        msgSuccess "yes"
    else
        msgWarn "no"
        unpackGCC
    fi

    # binutils
    getBinutilsVersion

    msgStatus "Checking if latest binutils version already downloaded"
    if [[ -f ./files/binutils-$BINUTILS_LATEST_VERSION.tar.gz ]]; then
        msgSuccess "yes"
    else
        msgWarn "no"
        getBinutilsSource
    fi

    msgStatus "Checking if latest binutils version already unpacked"
    if [[ -d ./source/binutils-$BINUTILS_LATEST_VERSION ]]; then
        msgSuccess "yes"
    else
        msgWarn "no"
        unpackBinutils
    fi

    exit 0
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

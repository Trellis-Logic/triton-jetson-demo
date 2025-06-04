#!/bin/bash
set -e
source $(dirname $0)/environment.sh

function printusage() {
    echo "Sets up the model repo with downloaded and converted tao model files"
    echo "Usage: $0 version"
    echo "  where version is one of ${!versions[@]}"
}

if [ $# -ne 1 ]; then
    echo "Invalid number of arguments"
    printusage
    exit 1
fi

version=$1
if [ ! -d $BASE_DIR/$version ]; then
    echo "$version directory does not exist in $BASE_DIR - did you run download_and_convert script?"
    printusage
    exit 1
fi

if [ ! -e $BASE_DIR/$version/model.plan ]; then
    echo "model.plan file does not exist in $BASE_DIR/$version - did you run download_and_convert script?"
    printusage
    exit 1
fi

if [ ! -e $BASE_DIR/$version/config.pbtxt ]; then
    echo "config.pbtxt file does not exist in $BASE_DIR/$version - did you run download_and_convert script?"
    printusage
    exit 1
fi

if [ ! -e $BASE_DIR/$version/labels.txt ]; then
    echo "labels.txt file does not exist in $BASE_DIR/$version - did you run download_and_convert script?"
    printusage
    exit 1
fi

rm -rf $TRITON_MODEL_REPO_DIR/*
deploydir=$TRITON_MODEL_REPO_DIR/${version_dir[${version}]}
mkdir -p $deploydir
cp $BASE_DIR/$version/model.plan $deploydir
cp $BASE_DIR/$version/config.pbtxt $TRITON_MODEL_REPO_DIR
cp $BASE_DIR/$version/labels.txt $TRITON_MODEL_REPO_DIR
echo "Copied model files for version $version from $BASE_DIR/$version to $TRITON_MODEL_REPO_DIR"

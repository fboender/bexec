#!/bin/sh

if [ -z $1 ]; then
    echo "Usage: mkrelease.sh <version>"
    exit;
fi

# Pre-clean

# Documentation

# Unix (src) release
vim -s ./release.vim
mv bexec.vba bexec-$1.vba

# Cleanup.


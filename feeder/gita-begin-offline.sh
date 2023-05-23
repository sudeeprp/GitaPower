#!/bin/bash
set -e
set -x

cd gita-begin
mkdir -p compile
mkdir -p gita
git clone https://github.com/rapalearning/gita-begin content-hold
mv content-hold/compile/*.json compile
mv content-hold/gita/* gita
rm -rf content-hold
cd -

#!/bin/bash
set -e

rm -rf public
git clone -b master git@github.com:takus/takus.github.com.git public

hugo

cd public
git add .
git commit --allow-empty -m "Site updated at $(date -u --iso-8601=seconds)"
git push origin master

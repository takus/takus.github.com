#!/bin/bash
set -e

cd public
rm -rf *

cd .. && hugo

cd public
git add .
git commit -m "Site updated at $(date -u --iso-8601=seconds)"
git push origin master

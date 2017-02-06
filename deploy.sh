#!/bin/sh
cp CNAME _site/CNAME
cp robots.txt _site/robots.txt
cd _site

MESSAGE=$(date +"%m-%d-%Y %T")

git init
git remote add origin https://github.com/antipornosk/antipornosk.github.io.git
git add .
git commit -m "$MESSAGE"
git push origin master -f

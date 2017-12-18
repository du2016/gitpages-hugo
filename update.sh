#!/bin/bash
hugo
MSG=$1
git add .
git commit -m ${MSG}
git push origin master
cd public
git add .
git commit -m ${MSG}
git push origin master

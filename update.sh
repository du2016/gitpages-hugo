#!/bin/bash
./hugo
cd public
git add .
git commit -m "update"
git push origin master

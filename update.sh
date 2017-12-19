#!/bin/bash
./hugo
cd public
git add .
git commit -m ${MSG}
git push origin master

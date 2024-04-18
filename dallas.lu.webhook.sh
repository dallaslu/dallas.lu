#!/bin/sh

git pull

status_log=$(git status -sb)

if [ "$status_log" = "## main...origin/main" ];then
        echo "nothing"
else
        echo "[dallas.lu] commit..."
        # git config --global user.email <>
        git add .
        git commit -m "update" -a
fi

git push


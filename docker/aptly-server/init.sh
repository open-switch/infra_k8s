#!/bin/bash -eu

echo "$APTLY_KEY" | gpg --import

ln -sf /usr/share/nginx/index.html /usr/share/nginx/html/index.html

aptly api serve -no-lock &

nginx -g "daemon off;"

#!/bin/bash -xeu

pkgs=(
opx-dell-s4248fb
opx-dell-s5148f
opx-dell-s6000
opx-dell-vm
)

apt-get update

for p in "${pkgs[@]}"; do
  debtree --no-versions "$p" | gvpr -i 'N[name == "*opx*"]' >"$p.dot"
done

# https://stackoverflow.com/a/16506160
gvpack -u ./*.dot \
| sed -e 's/_gv[0-9]\+//g' -e 's/digraph/strict digraph/g' \
| dot -Tsvg -o/usr/share/nginx/html/deps.svg


#!/bin/bash
cd "$(dirname "$0")"
nonce=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
mkdir -p ../dist
for tplfile in *.patc_; do
  output="../dist/$(basename $tplfile ".patc_").patch"
  sed "s/%%secret_placeholder%%/$nonce/g" "$tplfile" > $output
done
sed "s/%%secret_placeholder%%/$nonce/g" "nginx_site.con_" > "../dist/nginx_site.conf"

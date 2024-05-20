#!/bin/sh
#########################################
# The mandatory parameters example      #
#########################################
# ACCOUNT_EMAIL=xxxxxxx@qq.com
# my_domain="xxx.cc"
# my_domain_dns="dns_huaweicloud"
#
# ACCOUNT_EMAIL=xxxxxxx@gmail.com
# my_domain="xxx.xyz"
# my_domain_dns="dns_cf"
#########################################

if [ x"$my_domain_dns" = "x" -o x"$my_domain" = "x" x"$ACCOUNT_EMAIL$CA_EMAIL" = "x" ]; then
    echo "Missing mandatory parameters! Exit..."
    exit 1
fi

acme.sh --issue --dns $my_domain_dns -d "$my_domain" -d "*.$my_domain" --ecc --keylength ec-384 --debug
mkdir -p /etc/nginx/ssl/$my_domain
acme.sh --install-cert -d $my_domain --cert-file /etc/nginx/ssl/$my_domain/cert.pem --key-file /etc/nginx/ssl/$my_domain/key.pem --fullchain-file /etc/nginx/ssl/$my_domain/fullchain.pem --ecc --reloadcmd "chown 0:33 -R /etc/nginx/ssl/* && chmod 750 -R /etc/nginx/ssl/* && docker exec nginx /bin/bash -c \"nginx -t && nginx -s reload\""

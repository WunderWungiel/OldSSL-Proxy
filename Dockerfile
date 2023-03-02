FROM alpine:3.13
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
EXPOSE 3128/tcp 3180/tcp

RUN apk add alpine-sdk squid openssl tini darkhttpd && \
    /usr/lib/squid/security_file_certgen -c -s /var/cache/squid/ssl_db -M 4MB && \
    chown squid:squid -R /var/cache/squid/ssl_db && \
    mkdir /etc/squid/ssl_cert && \
    \
    cd /etc/squid/ && \
    sed -i 's/http_port 3128/#http_port 3128/' squid.conf && \
    sed -i 's/http_access deny !Safe_ports/#http_access deny !Safe_ports/' squid.conf && \
    sed -i 's/http_access deny CONNECT !SSL_ports/#http_access deny CONNECT !SSL_ports/' squid.conf && \
    \
    echo 'http_port 3128 ssl-bump \' >> squid.conf  && \
    echo '    cert=/etc/squid/ssl_cert/myCA.pem \' >> squid.conf  && \
    echo '    cipher=HIGH:MEDIUM:!LOW:!aNULL:!eNULL:!MD5:!EXP:!PSK:!SRP:!DSS \' >> squid.conf  && \
    echo '    options=NO_TICKET,ALL \' >> squid.conf  && \
    echo '    generate-host-certificates=on dynamic_cert_mem_cache_size=4MB' >> squid.conf  && \
    echo '' >> squid.conf  && \
    echo 'visible_hostname squid-oldssl-proxy' >> squid.conf  && \
    echo 'ssl_bump bump all' >> squid.conf  && \
    echo 'tcp_outgoing_address 0.0.0.0' >> squid.conf  && \
    echo 'sslproxy_cert_sign_hash sha1' >> squid.conf  && \
    \
    adduser user -D -G abuild && \
    \
    su user bash -c 'cd && git clone https://github.com/alpinelinux/aports.git --depth 1' && \
    su user bash -c 'abuild-keygen -a < /dev/null' && \
    cd /home/user/aports/main/openssl/ && \
    \
    sed -i 's/no-ssl3/enable-ssl3 enable-ssl3-method/' APKBUILD && \
    sed -i 's/no-weak-ssl-ciphers/enable-weak-ssl-ciphers/' APKBUILD && \
    \
    su user bash -c 'cd /home/user/aports/main/openssl/ && abuild -r' && \
    \
    cd /home/user/packages/main/*/ && \
    apk add --allow-untrusted libcrypto*.apk libssl*.apk openssl-1.*.apk && \
    \
    apk del alpine-sdk && \
    deluser --remove-home user && \
    rm -rf /var/cache/apk/* && \
    \
    echo '#!/bin/sh' > /usr/local/bin/entrypoint.sh && \
    echo 'if [[ ! -f /etc/squid/ssl_cert/myCA.pem ]]; then' >> /usr/local/bin/entrypoint.sh && \
    echo 'cd /etc/squid/ssl_cert' >> /usr/local/bin/entrypoint.sh && \
    echo 'mkdir public' >> /usr/local/bin/entrypoint.sh && \
    echo "openssl req -new -newkey rsa:1024 -sha1 -days 1825 -nodes -x509 -extensions v3_ca -subj '/C=AU/ST=Some-State/O=OldSSL Proxy' -keyout myCA.pem -out myCA.pem -batch" >> /usr/local/bin/entrypoint.sh && \
    echo 'openssl x509 -in myCA.pem -outform DER -out public/OldSSL.der' >> /usr/local/bin/entrypoint.sh && \
    echo 'openssl x509 -in myCA.pem -outform PEM -out public/OldSSL.crt' >> /usr/local/bin/entrypoint.sh && \
    echo 'fi' >> /usr/local/bin/entrypoint.sh && \
    echo 'chown squid:squid -R /etc/squid/ssl_cert/' >> /usr/local/bin/entrypoint.sh && \
    echo 'darkhttpd /etc/squid/ssl_cert/public/ --port 3180 --daemon' >> /usr/local/bin/entrypoint.sh && \
    echo 'exec squid --foreground' >> /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/entrypoint.sh

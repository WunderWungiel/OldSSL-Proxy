# SSL/TLS (HTTPS) proxy server for outdated operating systems like Windows XP

With OldSSL Proxy you can browse all HTTPS websites on Windows XP, old Symbian and Windows Mobile smartphones, as well as use other (non-browser) software with modern SSL/TLS internet hosts.

![Qualys SSL client test: TLS 1.3 support on Windows XP with Internet Explorer 6](https://bytebucket.org/ValdikSS/oldssl-proxy/raw/0b21285d3bce558686c7b76fd7016835137368df/winxp-tls13.png)

-----

OldSSL Proxy is a pre-configured Squid proxy server for outdated operating systems which do not support modern cryptography. It hijacks HTTPS connection (performs Man-in-the-Middle) and reencrypts it with self-signed certificate and old ciphersuites, compatible with old OS.

OldSSL Proxy:

* Performs "downgrading" Man-in-the-Middle for SSL/TLS (HTTPS)
* Supports SSLv3, RC4 and 3DES ciphers
* Uses RSA 1024 bit certificate with SHA1 signature
* Tested on Windows XP SP0 (Internet Explorer 6)

-----

## How to install

You'll need x86_64 system with **Docker** or **Podman**. Refer to [Docker installation instruction](https://www.docker.com/get-started) if you're not familiar with it.

Execute:

```
docker run -d -p 3128:3128 -p 3180:3180 -v oldproxy-certs:/etc/squid/ssl_cert valdikss/oldssl-proxy
```

The command will download [oldssl-proxy image](https://hub.docker.com/r/valdikss/oldssl-proxy) and execute it.

**WARNING**: this command will run unprotected proxy server accessible for everyone over the network. If run it on an internet-wide accessible server, make sure to configure firewall rules first!

-----

## How to use

1. Open browser, navigate to `http://PROXY-IP-ADDRESS:3180/`, where `PROXY-IP-ADDRESS` is an IP address of the Docker server.
2. Download `OldSSL.crt` *or* `OldSSL.der` — these are root certificate (certificate authority) files of the proxy. The files are the same but the format is different, some operating systems support only one them.
3. Import OldSSL certificate into certificate storage. On Windows XP just double-click on the file, next-next-yes-finish.
4. Configure your operating system (or browser) to use HTTP proxy. Host: `PROXY-IP-ADDRESS`, port `3128`.

-----

# Alternatives

Projects with the similar goals:

1. [mitmproxy-oldssl—Docker image of mitmproxy with OpenSSL reconfigured to enable SSLv3; can be configured to act as an SSL downgrade proxy for old machines][1]
2. [WebOne—HTTP 1.x proxy that makes old web browsers usable again in the Web 2.0 world. ][2]

[1]: https://github.com/ticky/mitmproxy-oldssl
[2]: https://github.com/atauenis/webone

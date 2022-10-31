# SSL self sign
## Generating SSL Certificates
https://www.digitalocean.com/community/tutorials/openssl-essentials-working-with-ssl-certificates-private-keys-and-csrs
```bash
openssl req \
       -newkey rsa:2048 -nodes -keyout server.key \
       -x509 -days 365 -subj "/C=TH/ST=BKK/O=KMITL/OU=IT"
       -out server.crt
```
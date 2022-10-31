# SSL self sign
## Generating SSL Certificates
https://www.digitalocean.com/community/tutorials/openssl-essentials-working-with-ssl-certificates-private-keys-and-csrs
```bash
openssl req \
       -newkey rsa:2048 -nodes -keyout server.key \
       -x509 -days 365 -out server.crt
```
Enter (empty)
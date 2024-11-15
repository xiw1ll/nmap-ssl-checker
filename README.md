# nmap-ssl-checker
## Intro
During tests i've found a strange behavior with HTTP sites on unusual ports that are redirecting to the HTTPS. Nmap couldn't identify that this HTTP site using HTTPS:
```bash
nmap <hidden> -p 9999 -sC -sV -oX - -vvv -sT -Pn
```
Output:
```xml
...
<ports><port protocol="tcp" portid="9999"><state state="open" reason="syn-ack" reason_ttl="0"/><service name="http" product="nginx" tunnel="ssl" method="probed" conf="10"><cpe>cpe:/a:igor_sysoev:nginx</cpe></service><script id="http-title" output="Did not follow redirect to https://<hidden>:9999/"><elem key="redirect_url">https://<hidden>:9999/</elem>
...
```
First things first it did not follow redirect (but http-title.nse tells that it can do it) [sometimes it redirects, but sometimes is not, idk why], the second strange things is `-sV` flag, if i'm removing it i will retrieve info about ssl certificate:
```bash
 nmap <hidden> -p 9999 -sC -oX - -vvv -sT -Pn
```
Output:
```xml
<ports><port protocol="tcp" portid="9999"><state state="open" reason="syn-ack" reason_ttl="0"/><service name="abyss" method="table" conf="3"/><script id="ssl-cert" output="Subject: commonName=<hidden>&#xa;Subject Alternative Name: DNS:<hidden>, DNS:<hidden>&#xa;Issuer: commonName=E5/organizationName=Let&apos;s Encrypt/countryName=US&#xa;Public Key type: ec&#xa;Public Key bits: 384&#xa;Signature Algorithm: ecdsa-with-SHA384&#xa;Not valid before: 2024-09-20T02:21:31&#xa;Not valid after:  2024-12-19T02:21:30&#xa;MD5:   9a3b:8541:5f5e:54dc:4ab3:d26f:fda3:8600&#xa;SHA-1: 7381:a16c:613d:4252:cf25:250e:61e3:5a16:7bae:25cb&#xa;-&#45;&#45;&#45;&#45;BEGIN CERTIFICATE-&#45;&#45;&#45;&#45;&#xa;MIIDqjCCAzGgAwIBAgISAwNkdigV6UhnIWd0M0DV72f0MAoGCCqGSM49BAMDMDIx&#xa;CzAJBgNVBAYTAlVTMRYwFAYDVQQKEw1MZXQncyBFbmNyeXB0MQswCQYDVQQDEwJF&#xa;NTAeFw0yNDA5MjAwMjIxMzFaFw0yNDEyMTkwMjIxMzBaMBkxFzAVBgNVBAMTDm1l&#xa;ZGlhbG9va3MuY29tMHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEmkayzG2ZgADXe8Q6&#xa;e81NByGtBmY07gK6JhskLkF0XfaYhNZpU7B+n8SWx/RZ/FmPDtUFClEkArAvysYG&#xa;RdqVn4yxpVD3AaDEYOiu/IsgSJaU7h7YDjWY6Vhcy4dJhDDjo4ICITCCAh0wDgYD&#xa;VR0PAQH/BAQDAgeAMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjAMBgNV&#xa;HRMBAf8EAjAAMB0GA1UdDgQWBBRtrg7mKi5wWNTUINihjY3p9SvyDjAfBgNVHSME&#xa;GDAWgBSfK1/PPCFPnQS37SssxMZwi9LXDTBVBggrBgEFBQcBAQRJMEcwIQYIKwYB&#xa;BQUHMAGGFWh0dHA6Ly9lNS5vLmxlbmNyLm9yZzAiBggrBgEFBQcwAoYWaHR0cDov&#xa;L2U1LmkubGVuY3Iub3JnLzArBgNVHREEJDAighAqLm1lZGlhbG9va3MuY29tgg5t&#xa;ZWRpYWxvb2tzLmNvbTATBgNVHSAEDDAKMAgGBmeBDAECATCCAQMGCisGAQQB1nkC&#xa;BAIEgfQEgfEA7wB1AEiw42vapkc0D+VqAvqdMOscUgHLVt0sgdm7v6s52IRzAAAB&#xa;kg1xmNsAAAQDAEYwRAIgX8f1hTmqyCF8+GPtP84Q86vbdGqWEu39bgEo1dMvUBYC&#xa;IB8vmGo7ReNSueqjEIUMeTvBBcN7M9fn2R54naPbXkV0AHYAPxdLT9ciR1iUHWUc&#xa;hL4NEu2QN38fhWrrwb8ohez4ZG4AAAGSDXGY4QAABAMARzBFAiEA16Vd+iILhowc&#xa;fA6IOuUWMpHsYwfggKPMHPb8b7qNABICIECzpF71h5z+s1RGgwPkVJoZ2bEiUCtO&#xa;aXFr1oEJMUDiMAoGCCqGSM49BAMDA2cAMGQCMCNKkdWaFLeMFagTToHkibSuIgFF&#xa;POX5ZKhrUKzv/nv8gQ694SBgZPjXkEoP+6e4QQIwT7jVDt/bN6nO+lcTHQHOvPdp&#xa;UOkcgo7tMf10sHwQPYfBEXwd8slogz8hXyDBcnEI&#xa;-&#45;&#45;&#45;&#45;END CERTIFICATE-&#45;&#45;&#45;&#45;&#xa;"><table key="subject">
```

So i think the issue is in the version detection mechanism, especially in nmap-service-probes file that have rules for ssl for default ports, but not for unusual ones.

Here come this script that have portrule that checks all open tcp ports for ssl =)

## Installation
Just upload ssl-checker.nse to the nmap directory (by default it's `/usr/share/nmap/scripts/`):
```bash
sudo cp ssl-checker.nse /usr/share/nmap/scripts
```
After that we have to reconfigure the nmap script database:
```bash
sudo nmap --script-updatedb
```
That's all ;)

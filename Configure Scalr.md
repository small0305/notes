# Set up Steps
## Add cloud credentials
> keystone url : 10.200.43.31:5000/v2.0

> username:admin

# Get started with Scalr
## Create a Role.
[Roles](https://scalr-wiki.atlassian.net/wiki/display/docs/Roles)
> Roles in Scalr are abstract (because they do not include all the information needed to launch Servers) and reusable (because you can use them multiple times, and share them) infrastructure components.

We [Clone an Existing Role](https://scalr-wiki.atlassian.net/wiki/display/docs/Clone+an+Existing+Role).

To get the [Packages - Sync Shared Roles](https://scalr-wiki.atlassian.net/wiki/display/docs/Packages+-+Sync+Shared+Roles), we applied. And we do as the website ask, but the roles are not be synchromized.

# Track the Process
## find the pid
```sudo netstat -antup | grep :80```
> tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      6444/httpd

```[root@localhost ~]# ps -ef | grep 6444```
> root      6444  6390  0 11:24 ?        00:00:00 /opt/scalr-server/embedded/bin/httpd -f /opt/scalr-server/etc/httpd/httpd.conf -DFOREGROUND

```
[root@localhost ~]# cd /opt/scalr-server/
[root@localhost scalr-server]# cd bin/
[root@localhost bin]# /opt/scalr-server/embedded/bin/httpd -h
```
>  -f file            : specify an alternate ServerConfigFile

```[root@localhost bin]# vim /opt/scalr-server/etc/httpd/httpd.conf```

```# Proxy #

    LoadModule proxy_module                 embedded/modules/mod_proxy.so

    LoadModule slotmem_shm_module           embedded/modules/mod_slotmem_shm.so
    LoadModule proxy_balancer_module        embedded/modules/mod_proxy_balancer.so
    LoadModule lbmethod_byrequests_module   embedded/modules/mod_lbmethod_byrequests.so

    LoadModule proxy_http_module            embedded/modules/mod_proxy_http.so


    Listen 0.0.0.0:80

    <VirtualHost 0.0.0.0:80>
        ProxyPass /graphics           balancer://graphics/
        ProxyPass /load_statistics    balancer://plotter/
        ProxyPass /                   balancer://app/

        # Add X-Forwarded-For header, but discard anything coming from upstream.
        # TODO - Make this configurable
        RequestHeader unset X-Forwarded-For
        ProxyAddHeaders On
        ProxyAddHeaders On

      ErrorLog  /opt/scalr-server/var/log/httpd/web.proxy.error.log
      <IfModule log_config_module>
            CustomLog /opt/scalr-server/var/log/httpd/web.proxy.access.log combined
      </IfModule>



    </VirtualHost>

    <Proxy balancer://app>
        BalancerMember http://127.0.0.1:6270
    </Proxy>

    <Proxy balancer://graphics>
        BalancerMember http://127.0.0.1:6271
    </Proxy>

    <Proxy balancer://plotter>
        BalancerMember http://127.0.0.1:6272/load_statistics
```

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
> Usage: /opt/scalr-server/embedded/bin/httpd [-D name] [-d directory] [-f file]
                                            [-C "directive"] [-c "directive"]
                                            [-k start|restart|graceful|graceful-stop|stop]
                                            [-v] [-V] [-h] [-l] [-L] [-t] [-T] [-S] [-X]
Options:
  -D name            : define a name for use in <IfDefine name> directives
  -d directory       : specify an alternate initial ServerRoot
  -f file            : specify an alternate ServerConfigFile
  -C "directive"     : process directive before reading config files
  -c "directive"     : process directive after reading config files
  -e level           : show startup errors of level (see LogLevel)
  -E file            : log startup errors to file
  -v                 : show version number
  -V                 : show compile settings
  -h                 : list available command line options (this page)
  -l                 : list compiled in modules
  -L                 : list available configuration directives
  -t -D DUMP_VHOSTS  : show parsed vhost settings
  -t -D DUMP_RUN_CFG : show parsed run settings
  -S                 : a synonym for -t -D DUMP_VHOSTS -D DUMP_RUN_CFG
  -t -D DUMP_MODULES : show all loaded modules 
  -M                 : a synonym for -t -D DUMP_MODULES
  -t                 : run syntax check for config files
  -T                 : start without DocumentRoot(s) check
  -X                 : debug mode (only one worker, do not detach)


# Installing Scalr 

Instruction: 
https://scalr-wiki.atlassian.net/wiki/display/docs/Installation+and+Upgrade+Instructions 

## Downloading and Installing the Scalr package 
CentOS 7.x is RHEL-Based. 
So we tried following commands:

## Install the repository
```
curl -L https://packagecloud.io/install/repositories/scalr/scalr-server-oss/script.rpm | sudo bash
```
## Install Scalr
```
sudo yum install -y scalr-server
```

And it is said:
> Another app is currently holding the yum lock; waiting for it to exit...

This command may solve the problem above:
```
rm -f /var/run/yum.pid
```
However the address of mirror file has changed, so we can't download again.

So I copy the installation file from Zheng Chaoyue.

# Configure Scalr
```
# Generate (and display) the default configuration files.
sudo /opt/scalr-server/bin/scalr-server-wizard 
```

```
# Reload/restart all scalr components with the new configuration
sudo /opt/scalr-server/bin/scalr-server-ctl reconfigure
```

# Accessing Scalr
To get IP of our server:
```
ip r 
```
> default via 192.168.236.2 dev eno16777736  proto static  metric 1024 

> 192.168.122.0/24 dev virbr0  proto kernel  scope link  src 192.168.122.1 

> 192.168.236.0/24 dev eno16777736  proto kernel  scope link  src 192.168.236.128

And ``192.168.236.128`` is our IP.

To get the password, we need to read the “*.json” file, which need the authority.

So first we change to root:
```
	su -
```
And then we read the file:
```
	cd ..
	cd etc\scalr-server
	cat scalr-server-secrets.json
```
> { 

>  "mysql": { 
>    "root_password": "69d2fd8e0849726925bd711f38957d79f7aa6423a24debd61f527c9253171e74aa13d633e351ad491e5b7ec8670a4f0fad4c", 
>    "scalr_password": "206a31600f5a7e94aa4eda688034a8019e093e009328d77a835c83d2c0f9a1cdb95cdca83054ac6f38f089a9f419b42427f7",
>    "repl_password": "be1f47ea9d3c8c08c3a50472" 
>  }, 
  
> "memcached": { 
>    "password": "e2fff22be38dc88cddf060cc7c21daebcec1ec99faa7b31c92f3cf40a234b5e84f449c8e30802bb87e35792acb69d8b770b8" 
>  }, 
  
> "app": { 
>    "admin_password": "38feaac3a6bc3ecc9a27a112", 
>    "secret_key": "wOKb4NNUA0flHJo3IcXKHLyJoMDfHf5tqw5bJttMxhHJeRjKHfT+5qXaUTe+2P4z8UCN9TxT1v2dFLSn4YrruEJG5WS36oQ7fLVINdJLXLJxFV36JBVOhWj5HHAVDjW9D4BATEEuvwtrEBRLhCGXOg3/sVbWNqYeEqxR06rnyuZqunxD6fwNolPD4gsAJYG1JyH2kTED7cCZWWqaOzUf3jAjYAzuhdx/mUGUlugoWtQqBLzHgnsmS+MAFhuvxlUXwucIyp4vJZ8DZ4Thn6N2pSNqTfiR1397bS8Ft/BUzj+Fa6UeBC8D2qWW/QAKJljqyGHXJKklaXFxI/Az2H81EyyEOGecOdCSSAqHsf4/KWyhHRTFiIr/jhede99ydAGCdkPScar49xN1r9grGY/zhUpjQ2gpIXaJAVn+MTtp62k1JhnykWNnDdF7XbCE5vXk3Fst3zq1e3Gc7hFDdLpcm0Y1TvbjbxoPB6zWPP//7GlceE0hqmb+Ar21eCUclcUYLAYbXfIUeyLRppJhevrC4MvGyqGOpJ/p9/KlxEpA1127HOmSTHsNjKpAQfENwJFL/LBo9l98Be4/5Z6cYi9np9q4NhcegKSCm2Z1t+1wwqNZxoOYPzcftjbi8gqm4zzPagT8tkMJk/8K0AaxDjV9C4k5JtPdvS8yObPcBM5eVi8=", 
>    "id": "d48bb202" 
>  } 
>} 

And our password is "38feaac3a6bc3ecc9a27a112".

Email:taor@rc.inesa.com

password:Small_18817560531

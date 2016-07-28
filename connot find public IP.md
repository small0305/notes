## problem: cannot find public id when import from a non-scalr server

### step 1
首先要知道scalr不显示public，是因为云主机没有把ip传给它，还是因为传给它了，但是它读不出来。

需要下载抓包软件 wireshark。

为了获得更快的下载速度，这里对[yum源](http://www.cnblogs.com/mchina/archive/2013/01/04/2842275.html)进行了配置，添加了阿里云。

安装好wireshark后，`wireshark &` 启动wireshark。

Capture Interfaces选择：eno16777735（IP 10.200.44.82）。

filter设置为：

`ip.addr eq 10.200.43.31` (云平台的IP)

或 `tcp.stream eq 8`

找到本机与服务器通信的记录，右键选择 “Follow TCP Stream”。

在弹出的窗口可以看到通信的报文及附加的js。

``` json
GET /v2/0d0591bc520048f9acdc492403f0b51f/servers/detail HTTP/1.1

User-Agent: Scalr/5.10.21 (Community Edition; c234393.d48bb202)

Host: 10.200.43.31:8774

Accept: application/json

Content-Type: application/json; charset=UTF-8

X-Auth-Token: bf829d891a46473a9336888895ec6d5e



HTTP/1.1 200 OK

Content-Type: application/json

Content-Length: 1660

X-Compute-Request-Id: req-5d907a85-696e-47d8-bd5a-b22c9e4187b4

Date: Tue, 26 Jul 2016 05:03:07 GMT



{"servers": [
	{"status": "ACTIVE", "updated": "2016-07-25T08:36:54Z", "hostId": "c4a505e1d62ad84003d9b23716ff50cedb8be0bc3cc5bc3d4af36abd", "addresses": 
		{"private": [
			{"OS-EXT-IPS-MAC:mac_addr": "fa:16:3e:d0:fa:b8", "version": 4, "addr": "10.0.0.4", "OS-EXT-IPS:type": "fixed"}, 
			{"OS-EXT-IPS-MAC:mac_addr": "fa:16:3e:d0:fa:b8", "version": 4, "addr": "10.200.43.98", "OS-EXT-IPS:type": "floating"}]}, 
		"links": [
			{"href": "http://10.200.43.31:8774/v2/0d0591bc520048f9acdc492403f0b51f/servers/2b4c81fd-3ee6-4167-bba2-ced6415a3e73", "rel": "self"}, 
			{"href": "http://10.200.43.31:8774/0d0591bc520048f9acdc492403f0b51f/servers/2b4c81fd-3ee6-4167-bba2-ced6415a3e73", "rel": "bookmark"}], 
		"key_name": 
			"cloud", 
		"image": 
			{"id": "995873c3-66c9-4225-a248-3dfdaa4e5cff", "links": [{"href": "http://10.200.43.31:8774/0d0591bc520048f9acdc492403f0b51f/images/995873c3-66c9-4225-a248-3dfdaa4e5cff", "rel": "bookmark"}]}, 
		"OS-EXT-STS:task_state": null, 
		"OS-EXT-STS:vm_state": "active", 
		"OS-SRV-USG:launched_at": "2016-07-25T02:26:44.000000", 
		"flavor": 
			{"id": "3", "links": [{"href": "http://10.200.43.31:8774/0d0591bc520048f9acdc492403f0b51f/flavors/3", "rel": "bookmark"}]}, 
			"id": "2b4c81fd-3ee6-4167-bba2-ced6415a3e73", 
		"security_groups": [{"name": "default"}], 
		"OS-SRV-USG:terminated_at": null, "OS-EXT-AZ:availability_zone": "nova", "user_id": "3aeb2ad85f394d0b9a723d10e30c06bd", "name": "centos7-002", "created": "2016-07-25T02:26:39Z", "tenant_id": "0d0591bc520048f9acdc492403f0b51f", "OS-DCF:diskConfig": "AUTO", "os-extended-volumes:volumes_attached": [], "accessIPv4": "", "accessIPv6": "", "progress": 0, "OS-EXT-STS:power_state": 1, "config_drive": "", "metadata": {}}]}
```

在这里可以看到两个ip地址，私有和公有都传过来了，那么至少说明通信没有问题，问题是在scalr读取ip这个过程上。

### step 2
接下来要找到是哪个函数在做着读取ip的操作。

在浏览器中按<kbd>F12</kbd>，在下面可以看到：

> http://0.0.0.0/roles/import/xGetCloudServersList/

因此函数名是形如xGetCloudServersList这样的。

在terminal中在scalr-server文件夹下使用[grep](http://man.chinaunix.net/newsoft/grep/open.htm)命令 `# grep -rn 'xGetCloudServersList'`，返回项中有

> embedded/scalr/app/src/Scalr/UI/Controller/Roles/Import.php:259:    public function xGetCloudServersListAction($platform, $cloudLocation)


猜测此函数即为所找函数，遂打开文件。`# vim embedded/scalr/app/src/Scalr/UI/Controller/Roles/Import.php +259`

``` php
public function xGetCloudServersListAction($platform, $cloudLocation)
    {
        if (!$this->environment->isPlatformEnabled($platform))
            throw new Exception(sprintf('Cloud %s is not enabled for current environment', $platform));

        $results = array();

        $platformObj = PlatformFactory::NewPlatform($platform);

        if (PlatformFactory::isOpenstack($platform)) {
            $client = $this->environment->openstack($platform, $cloudLocation);
            $r = $client->servers->list(true);
            do {
                foreach ($r as $server) {
                    if ($server->status != 'ACTIVE')
                        continue;

                    $ips = $platformObj->determineServerIps($client, $server);

                    $itm = array(
                        'id' => $server->id,
                        'localIp' => $ips['localIp'],
                        'publicIp' => $ips['remoteIp'],
                        'zone' => $cloudLocation,
                        'isImporting' => false,
                        'isImporting' => false,
                        'isManaged' => false,
                        'fullInfo' => $server
                    );

                    //Check is instance already importing
                    try {
                        $dbServer = DBServer::LoadByPropertyValue(OPENSTACK_SERVER_PROPERTIES::SERVER_ID, $server->id);
                        if ($dbServer && $dbServer->status != SERVER_STATUS::TERMINATED) {
                            if ($dbServer->status == SERVER_STATUS::IMPORTING) {
                                $itm['isImporting'] = true;
                            } else {
                                $itm['isManaged'] = true;
                            }
                            $itm['serverId'] = $dbServer->serverId;
                        }
                    } catch (Exception $e) {
                    }

                    $results[] = $itm;
                }
            } while (false !== ($r = $r->getNextPage()));
        }
        $this->response->data(array(
            'data' => $results
        ));
    }
```

考虑到

> $ips = $platformObj->*determineServerIps($client, $server)*;

接下来找determineServerIps函数。`# grep -rn  'determineServerIps' *`

> embedded/scalr/app/src/Scalr/Modules/Platforms/Openstack/OpenstackPlatformModule.php:147:    public function determineServerIps(OpenStack $client, $server)

`# vim embedded/scalr/app/src/Scalr/Modules/Platforms/Openstack/OpenstackPlatformModule.php +147`

## step 3
最后要阅读所找到的函数，看问题出在哪里，然后进行修改。

结合之前得到的服务器返回的JS代码，发现源代码对地址的判别方式有一些问题。

在privateIp不为空，publicIp为空的情况下，不进行后续语句的判断。

遂修改如下：
```php
    public function determineServerIps(OpenStack $client, $server)
    {
        $config = \Scalr::getContainer()->config;

/*
        $publicNetworkName = 'public';
        $privateNetworkName = 'private';

        if (is_array($server->addresses->{$publicNetworkName})) {
            foreach ($server->addresses->{$publicNetworkName} as $addr)
            if ($addr->version == 4) {
                $remoteIp = $addr->addr;
                break;
            }
        }

        if (is_array($server->addresses->{$privateNetworkName})) {
            foreach ($server->addresses->{$privateNetworkName} as $addr)
            if ($addr->version == 4) {
                $localIp = $addr->addr;
                
                break;
            }
        }

        if (!$localIp)
            $localIp = $remoteIp;
*/
//        if (!$localIp && !$remoteIp) {
        if (true) {
            $addresses = (array)$server->addresses;
            $addresses = array_shift($addresses);
            if (is_array($addresses)) {
                foreach ($addresses as $address) {
                    if ($address->version == 4) {
                        if(isset($address->{'OS-EXT-IPS:type'}) && $address->{'OS-EXT-IPS:type'}  == 'floating')
                            $remoteIp = $address->addr;
                        else {
                         //   if (strpos($address->addr, "10.") === 0 || strpos($address->addr, "192.168") === 0)
                            if (strpos($address->addr, "10.0") === 0 || strpos($address->addr, "192.168") === 0)
                                $localIp = $address->addr;
                            else
                                $remoteIp = $address->addr;
                        }
                    }
                }
            }
        }

        return array(
            'localIp'   => $localIp,
            'remoteIp'  => $remoteIp
        );
    }
```
该段代码路径为：
`/opt/scalr-server/embedded/scalr/app/src/Scalr/Modules/Platforms/Openstack/OpenstackPlatformModule.php`

<kbd>1</kbd>+<kbd>ctrl</kbd><kbd>g</kbd>返回全局路径。

## step 4
到github提交报告，然后看到此处代码已经被更新如下：
```php
public function determineServerIps(OpenStack $client, $server)
{
	$publicNetworkName = 'public';
	$privateNetworkName = 'private';
	$remoteIp = null;
	$localIp = null;
	$publicNetworkIpAddresses = null;
	$privateNetworkIpAddresses = null;
	if (!empty($server->addresses->{$publicNetworkName}))
		$publicNetworkIpAddresses = $server->addresses->{$publicNetworkName};
		if (!empty($server->addresses->{$privateNetworkName}))
			$privateNetworkIpAddresses = $server->addresses->{$privateNetworkName};
		// Use this method only if network has 1 IP address
		if (is_array($publicNetworkIpAddresses) && 	count($publicNetworkIpAddresses) == 1) {
			foreach ($server->addresses->{$publicNetworkName} as $addr) {
				if ($addr->version == 4) {
					$remoteIp = $addr->addr;
					break;
				}
			}
		}
		// Use this method only if network has 1 IP address
		if (is_array($privateNetworkIpAddresses) && count($privateNetworkIpAddresses) == 1) {
			foreach ($server->addresses->{$privateNetworkName} as $addr) {
				if ($addr->version == 4) {
					$localIp = $addr->addr;
					break;
				}
			}
		}
		if (empty($localIp) && !empty($remoteIp))
			$localIp = $remoteIp;
			if (empty($localIp) && empty($remoteIp)) {
				$addresses = (array)$server->addresses;
				$addresses = array_shift($addresses);
				if (is_array($addresses)) {
					foreach ($addresses as $address) {
						if ($address->version == 4) {
							if(isset($address->{'OS-EXT-IPS:type'}) && $address->{'OS-EXT-IPS:type'} == 'floating')
								$remoteIp = $address->addr;
						else {
							if (strpos($address->addr, "10.") === 0 || strpos($address->addr, "192.168") === 0)
								$localIp = $address->addr;
							else
								$remoteIp = $address->addr;
						}
					}
				}
			}
		}
	return array(
		'localIp'	=> $localIp,
		'remoteIp'	=> $remoteIp
	);
}
```

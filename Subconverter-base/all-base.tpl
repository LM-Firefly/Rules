{% if request.target == "clash" or request.target == "clashr" %}

port: {{ local.clash.http_port }}
socks-port: {{ local.clash.socks_port }}
redir-port: {{ local.clash.redir_port}}
allow-lan: {{ local.clash.allow_lan }}
mode: Rule
log-level: {{ local.clash.log_level }}
external-controller: {{ local.clash.api_port}}

secret: ''
experimental:
  ignore-resolve-fail: true
{% if exists("request.clash.dns") %}
{% if request.clash.dns == "cfw" %}
  interface-name: WLAN
#authentication:
#  - "firefly:960923"
hosts:
dns:
  enable: true
  ipv6: true
  listen: 127.0.0.1:53
{% endif %}
{% if request.clash.dns == "cfa" %}
#  interface-name: WLAN
#authentication:
#  - "firefly:960923"
hosts:
dns:
  enable: true
  ipv6: true
  listen: 127.0.0.1:1053
{% endif %}
{% else %}
#  interface-name: WLAN
#authentication:
#  - "firefly:960923"
hosts:
dns:
  enable: true
  ipv6: true
  listen: 127.0.0.1:1053
{% endif %}
  enhanced-mode: fake-ip # redir-host #fake-ip
  fake-ip-range: 198.18.0.1/16
  fake-ip-filter:
    - '*.lan'
    - msftconnecttest.com
    - '*.msftconnecttest.com'
    - msftncsi.com
    - '*.msftncsi.com'
    - localhost.ptlogin2.qq.com
    - localhost.sec.qq.com
    - '+.stun.*.*'
    - '+.stun.*.*.*'
    - '+.stun.*.*.*.*'
    - 'lens.l.google.com'
    - 'stun.l.google.com'
    - '*.n.n.srv.nintendo.net'
  nameserver:
    - 223.5.5.5
    - 119.29.29.29
    - https://dns.alidns.com/dns-query
    - https://cloudflare-dns.com/dns-query
    - https://dns.google/dns-query
    - https://doh.opendns.com/dns-query
    - https://dns.twnic.tw/dns-query
    - https://dns.quad9.net/dns-query
    - https://doh.qis.io/dns-query
    - https://doh.powerdns.org
    #    - 101.101.101.101
    #    - tcp://119.29.107.85:9090
    #    - https://doh.dns.sb/dns-query
    #    - https://dns.rubyfish.cn/dns-query
    #    - https://sdns.233py.com/dns-query
    #    - https://edns.233py.com/dns-query
    #    - tls://cloudflare-dns.com:853
    #    - tls://dns.google:853
    #    - tls://dns-tls.qis.io:853
  fallback:
    - https://dns.alidns.com/dns-query
    - https://dns.twnic.tw/dns-query
    - https://dns.quad9.net/dns-query
    - https://cloudflare-dns.com/dns-query
    - https://dns.google/dns-query
    - https://doh.qis.io/dns-query
    - https://doh.opendns.com/dns-query
    - https://doh.powerdns.org
    #   - tcp://1.1.1.1
    #    - https://doh.dns.sb/dns-query
    #    - https://dns.rubyfish.cn/dns-query
    #    - https://sdns.233py.com/dns-query
    #    - https://edns.233py.com/dns-query
    #    - tls://cloudflare-dns.com:853
    #    - tls://dns.google:853
    #    - tls://dns-tls.qis.io:853
  fallback-filter:
    geoip: true # default
    ipcidr: # ips in these subnets will be considered polluted
      - 240.0.0.0/4

{% endif %}
{% if request.target == "surge" %}

[General]
loglevel = notify
internet-test-url = http://connectivitycheck.gstatic.com/generate_204
proxy-test-url = http://connectivitycheck.gstatic.com/generate_204
test-timeout = 3
socks5-listen = 8828
http-listen = 8829
allow-wifi-access = true
wifi-access-http-port = 8838
wifi-access-socks5-port = 8839
external-controller-access = 6170@0.0.0.0:6155
skip-proxy = 10.0.0.0/8, 127.0.0.0/8, 169.254.0.0/16, 192.0.2.0/24, 192.168.0.0/16, 198.51.100.0/24, 224.0.0.0/4, *.local, localhostlocal,::ffff:0:0:0:0/1,::ffff:128:0:0:0/1
exclude-simple-hostnames = true
tls-provider = openssl
force-http-engine-hosts = 122.14.246.33, 175.102.178.52, mobile-api2011.elong.com
tun-excluded-routes = 10.0.0.0/8, 127.0.0.0/8, 169.254.0.0/16, 192.0.2.0/24, 192.168.0.0/16, 198.51.100.0/24, 224.0.0.0/4
dns-server = 119.29.29.29, 223.5.5.5

[Replica]
hide-apple-request=1
hide-crashlytics-request=1
hide-udp=0
keyword-filter-type=(null)
keyword-filter=(null)

[Proxy Group]

[Rule]

[URL Rewrite]
# Redirect Google Search Service
^http:\/\/www\.google\.cn https://www.google.com 302

[Header Rewrite]
# 百度贴吧
^https?+:\/\/(?:c\.)?+tieba\.baidu\.com\/(?>f|p) header-replace User-Agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.4 Safari/605.1.15"
^https?+:\/\/jump2\.bdimg\.com\/(?>f|p) header-replace User-Agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.4 Safari/605.1.15"
# 百度知道
^https?+:\/\/zhidao\.baidu\.com header-replace User-Agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.4 Safari/605.1.15"
# 知乎
^https?+:\/\/www\.zhihu\.com\/question header-replace User-Agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.4 Safari/605.1.15"

[MITM]

[Script]
http-request https?:\/\/.*\.iqiyi\.com\/.*authcookie= script-path=https://raw.githubusercontent.com/NobyDa/Script/master/Surge/iQIYI-DailyBonus/iQIYI_GetCookie.js

{% endif %}
{% if request.target == "loon" %}

[General]
skip-proxy = 192.168.0.0/16,10.0.0.0/8,172.16.0.0/12,localhost,*.local,e.crashlynatics.com
bypass-tun = 10.0.0.0/8,100.64.0.0/10,127.0.0.0/8,169.254.0.0/16,172.16.0.0/12,192.0.0.0/24,192.0.2.0/24,192.88.99.0/24,192.168.0.0/16,198.18.0.0/15,198.51.100.0/24,203.0.113.0/24,224.0.0.0/4,255.255.255.255/32
dns-server = system,119.29.29.29,223.5.5.5
allow-udp-proxy = true
host = 127.0.0.1

[Proxy]

[Remote Proxy]

[Proxy Group]

[Rule]

[Remote Rule]

[URL Rewrite]
enable = true
^https?:\/\/(www.)?(g|google)\.cn https://www.google.com 302

[Remote Rewrite]

[MITM]
hostname =
enable = true
skip-server-cert-verify = true
#ca-p12 =
#ca-passphrase =

{% endif %}
{% if request.target == "quan" %}

[SERVER]

[SOURCE]

[BACKUP-SERVER]

[SUSPEND-SSID]

[POLICY]

[DNS]
1.1.1.1

[REWRITE]

[URL-REJECTION]

[TCP]

[GLOBAL]

[HOST]

[STATE]
STATE,AUTO

[MITM]

{% endif %}
{% if request.target == "quanx" %}

[general]
dns_exclusion_list = *.cmbchina.com, *.cmpassport.com, *.jegotrip.com.cn, *.icitymobile.mobi, *.pingan.com.cn, id6.me
excluded_routes=10.0.0.0/8, 127.0.0.0/8, 169.254.0.0/16, 192.0.2.0/24, 192.168.0.0/16, 198.51.100.0/24, 224.0.0.0/4
geo_location_checker=http://ip-api.com/json/?lang=zh-CN, https://github.com/KOP-XIAO/QuantumultX/raw/master/Scripts/IP_API.js
network_check_url=http://connectivitycheck.gstatic.com/generate_204
server_check_url=http://connectivitycheck.gstatic.com/generate_204

[dns]
server=119.29.29.29
server=223.5.5.5
server=1.0.0.1
server=8.8.8.8

[policy]
static=♻️ 自动选择, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Auto.png
static=🔰 节点选择, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Proxy.png
static=🌍 国外媒体, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/GlobalMedia.png
static=🌏 国内媒体, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/DomesticMedia.png
static=Ⓜ️ 微软服务, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Microsoft.png
static=📲 电报信息, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Telegram.png
static=🍎 苹果服务, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Apple.png
static=🎯 全球直连, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Direct.png
static=🛑 全球拦截, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Advertising.png
static=🐟 漏网之鱼, direct, img-url=https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Final.png

[server_remote]

[filter_remote]

[rewrite_remote]

[server_local]

[filter_local]

[rewrite_local]

[task_local]

[mitm]

{% endif %}
{% if request.target == "mellow" %}

[Endpoint]
DIRECT, builtin, freedom, domainStrategy=UseIP
REJECT, builtin, blackhole
Dns-Out, builtin, dns

[Routing]
domainStrategy = IPIfNonMatch

[Dns]
hijack = Dns-Out
clientIp = 114.114.114.114

[DnsServer]
localhost
223.5.5.5
8.8.8.8, 53, Remote
8.8.4.4

[DnsRule]
DOMAIN-KEYWORD, geosite:geolocation-!cn, Remote
DOMAIN-SUFFIX, google.com, Remote

[DnsHost]
doubleclick.net = 127.0.0.1

[Log]
loglevel = warning

{% endif %}
{% if request.target == "surfboard" %}

[General]
allow-wifi-access = true
collapse-policy-group-items = true
dns-server = system, 119.29.29.29, 223.5.5.5, 1.1.1.1, 1.0.0.1, 8.8.8.8
enhanced-mode-by-rule = true
exclude-simple-hostnames = true
external-controller-access = surfboard@127.0.0.1:6170
hide-crashlytics-request = false
interface = 0.0.0.0
ipv6 = true
loglevel = notify
port = 8828
socks-interface = 0.0.0.0
socks-port = 8829
wifi-access-http-port=8838
wifi-access-socks5-port=8839
test-timeout = 5
internet-test-url = http://connectivitycheck.gstatic.com/generate_204
proxy-test-url = http://connectivitycheck.gstatic.com/generate_204

{% endif %}
{% if request.target == "sssub" %}
{
  "route": "bypass-lan-china",
  "remote_dns": "dns.google",
  "ipv6": false,
  "metered": false,
  "proxy_apps": {
    "enabled": false,
    "bypass": true,
    "android_list": [
      "com.eg.android.AlipayGphone",
      "com.wudaokou.hippo",
      "com.zhihu.android"
    ]
  },
  "udpdns": false
}

{% endif %}

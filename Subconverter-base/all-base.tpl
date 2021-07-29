{% if request.target == "clash" or request.target == "clashr" %}

mixed-port: {{ local.clash.mixed_port }}
redir-port: {{ local.clash.redir_port}}
#authentication:
#  - "firefly:WJ960923"
allow-lan: {{ local.clash.allow_lan }}
bind-address: '*'
mode: rule
log-level: {{ local.clash.log_level }}
external-controller: {{ local.clash.api_port}}
#external-ui: folder

secret: ''
#interface-name: en0
profile:
  # store the `select` results in $HOME/.cache
  # when two different configurations have groups with the same name, the selected values are shared
  # set false if you don't want this behavior
  store-selected: true
  # open tracing exporter API
  tracing: true
{% if exists("request.clash.dns") %}
{% if request.clash.dns == "tap" %}
ipv6: true
#interface-name: WLAN
hosts:
dns:
  enable: true
  listen: 0.0.0.0:53
  ipv6: true
{% endif %}
{% if request.clash.dns == "tun" %}
ipv6: true
tun:
  enable: true
  stack: system # or gvisor
  dns-hijack:
    - 198.18.0.2:53 # when `fake-ip-range` is 198.18.0.1/16, should hijack 198.18.0.2:53
  macOS-auto-route: true # auto set global route for Windows
  macOS-auto-detect-interface: true # auto detect interface, conflict with `interface-name`
#interface-name: WLAN
hosts:
dns:
  enable: true
#  listen: 0.0.0.0:53
  ipv6: true
{% endif %}
{% if request.clash.dns == "cfa" %}
ipv6: true
tun:
  enable: true
  stack: system # or gvisor
#  dns-hijack:
#    - 198.18.0.2:53 # when `fake-ip-range` is 198.18.0.1/16, should hijack 198.18.0.2:53
#  macOS-auto-route: true # auto set global route for Windows
#  macOS-auto-detect-interface: true # auto detect interface, conflict with `interface-name`
#interface-name: WLAN
hosts:
dns:
  enable: true
  listen: 127.0.0.1:1053
  ipv6: true
{% endif %}
{% else %}
ipv6: true
hosts:
dns:
  enable: true
  listen: 127.0.0.1:1053
  ipv6: true
{% endif %}
  # These nameservers are used to resolve the DNS nameserver hostnames below.
  # Specify IP addresses only
  default-nameserver:
    - 223.5.5.5
    - 119.29.29.29
  enhanced-mode: fake-ip # redir-host #fake-ip
#  fake-ip-range: 198.18.0.1/16
  fake-ip-filter:
    # === LAN ===
    - '*.lan'
    - '*.localdomain'
    - '*.example'
    - '*.invalid'
    - '*.localhost'
    - '*.test'
    - '*.local'
    - '*.home.arpa'
    # === Linksys Wireless Router ===
    - '*.linksys.com'
    - '*.linksyssmartwifi.com'
    # === ASUS Router ===
    - '*.router.asus.com'
    # === Apple Software Update Service ===
    - 'swscan.apple.com'
    - 'mesu.apple.com'
    # === Windows 10 Connnect Detection ===
    - '*.msftconnecttest.com'
    - '*.msftncsi.com'
    - 'msftconnecttest.com'
    - 'msftncsi.com'
    # === Google ===
    - 'lens.l.google.com'
    - 'stun.l.google.com'
    ## Golang
    - 'proxy.golang.org'
    # === NTP Service ===
    - 'time.*.com'
    - 'time.*.gov'
    - 'time.*.edu.cn'
    - 'time.*.apple.com'
    - 'time1.*.com'
    - 'time2.*.com'
    - 'time3.*.com'
    - 'time4.*.com'
    - 'time5.*.com'
    - 'time6.*.com'
    - 'time7.*.com'
    - 'ntp.*.com'
    - 'ntp1.*.com'
    - 'ntp2.*.com'
    - 'ntp3.*.com'
    - 'ntp4.*.com'
    - 'ntp5.*.com'
    - 'ntp6.*.com'
    - 'ntp7.*.com'
    - '*.time.edu.cn'
    - '*.ntp.org.cn'
    - '+.pool.ntp.org'
    - 'time1.cloud.tencent.com'
    # === Game Service ===
    ## Nintendo Switch
    - '+.srv.nintendo.net'
    ## Sony PlayStation
    - '+.stun.playstation.net'
    ## Microsoft Xbox
    - 'xbox.*.microsoft.com'
    - 'xnotify.xboxlive.com'
    # === Other ===
    ## QQ Quick Login
    - 'localhost.ptlogin2.qq.com'
    - 'localhost.sec.qq.com'
    ## STUN Server
    - 'stun.*.*'
    - 'stun.*.*.*'
    - '+.stun.*.*'
    - '+.stun.*.*.*'
    - '+.stun.*.*.*.*'
  nameserver:
    - 223.5.5.5
    - 119.29.29.29
    - https://dns.alidns.com/dns-query
    - https://i.233py.com/dns-query
    - https://doh.pub/dns-query
    - https://dns.pub/dns-query
    - https://dns.cfiec.net/dns-query
    - https://dns.rubyfish.cn/dns-query
    - https://doh.mullvad.net/dns-query
#    - https://cdn-doh.ssnm.xyz/dns-query
#    - tls://dns.233py.com
#    - https://dns.233py.com/dns-query
#    - https://dns.twnic.tw/dns-query
#    - https://dns-unfiltered.adguard.com/dns-query
#    - https://doh.opendns.com/dns-query
#    - https://cloudflare-dns.com/dns-query
#    - https://dns.google/dns-query
#    - https://dns.quad9.net/dns-query
#    - https://doh.qis.io/dns-query
#    - https://doh.powerdns.org
#    - 101.101.101.101
#    - tcp://119.29.107.85:9090
#    - https://doh.dns.sb/dns-query
#    - tls://cloudflare-dns.com:853
#    - tls://dns.google:853
#    - tls://dns-tls.qis.io:853
  fallback:
    - https://doh.dns.sb/dns-query
    - https://dns.twnic.tw/dns-query
    - https://doh.opendns.com/dns-query
    - https://dns.233py.com/dns-query
    - https://public.dns.iij.jp/dns-query
    - https://doh.mullvad.net/dns-query
#    - https://doh.qis.io/dns-query
#    - https://dns-unfiltered.adguard.com/dns-query
#    - https://dns.quad9.net/dns-query
#    - https://cdn-doh.ssnm.xyz/dns-query
#    - https://dns.google/dns-query
#    - https://cloudflare-dns.com/dns-query
#    - tcp://1.1.1.1
#    - https://dns.alidns.com/dns-query
#    - https://doh.dns.sb/dns-query
#    - https://dns.rubyfish.cn/dns-query
#    - tls://cloudflare-dns.com:853
#    - tls://dns.google:853
#    - tls://dns-tls.qis.io:853
  fallback-filter:
    geoip: true # default
    ipcidr: # ips in these subnets will be considered polluted
      - 0.0.0.0/32
      - 100.64.0.0/10
      - 127.0.0.0/8
      - 240.0.0.0/4
      - 255.255.255.255/32

{% endif %}
{% if request.target == "surge" %}

[General]
ipv6 = true
loglevel = notify
http-listen = 8829
socks5-listen = 8828
allow-wifi-access = true
wifi-access-http-port = 8838
wifi-access-socks5-port = 8839
external-controller-access = 6170@0.0.0.0:6155
dns-server = system, 119.29.29.29, 223.5.5.5
doh-server = https://9.9.9.9/dns-query, https://dns.alidns.com/dns-query, https://i.233py.com/dns-query, https://doh.pub/dns-query, https://dns.pub/dns-query, https://dns.cfiec.net/dns-query, https://dns.rubyfish.cn/dns-query, https://doh.mullvad.net/dns-query, https://doh.dns.sb/dns-query, https://dns.twnic.tw/dns-query, https://doh.opendns.com/dns-query, https://dns.233py.com/dns-query, https://public.dns.iij.jp/dns-query, https://doh.mullvad.net/dns-query
hijack-dns = 8.8.8.8:53
always-real-ip = *.lan, *.localdomain, *.example, *.invalid, *.localhost, *.test, *.local, *.home.arpa, *.linksys.com, *.linksyssmartwifi.com, *.router.asus.com, swscan.apple.com, mesu.apple.com, *.msftconnecttest.com, *.msftncsi.com, msftconnecttest.com, msftncsi.com, lens.l.google.com, stun.l.google.com, proxy.golang.org, time.*.com, time.*.gov, time.*.edu.cn, time.*.apple.com, time1.*.com, time2.*.com, time3.*.com, time4.*.com, time5.*.com, time6.*.com, time7.*.com, ntp.*.com, ntp1.*.com, ntp2.*.com, ntp3.*.com, ntp4.*.com, ntp5.*.com, ntp6.*.com, ntp7.*.com, *.time.edu.cn, *.ntp.org.cn, *.pool.ntp.org, time1.cloud.tencent.com, *.srv.nintendo.net, *.stun.playstation.net, xbox.*.microsoft.com, xnotify.xboxlive.com, localhost.ptlogin2.qq.com, localhost.sec.qq.com, stun.*.*, stun.*.*.*, *.stun.*.*, *.stun.*.*.*, *.stun.*.*.*.*
tun-excluded-routes = 192.168.0.0/16, 10.0.0.0/8, 172.16.0.0/12
tun-included-routes = 192.168.1.12/32
tls-provider = openssl
exclude-simple-hostnames = true
skip-proxy = 127.0.0.1, 192.168.0.0/16, 10.0.0.0/8, 172.16.0.0/12, 100.64.0.0/10, localhost, *.local
force-http-engine-hosts = 122.14.246.33, 175.102.178.52, mobile-api2011.elong.com
internet-test-url = https://connectivitycheck.gstatic.com/generate_204
proxy-test-url = https://connectivitycheck.gstatic.com/generate_204
test-timeout = 3

[Replica]
hide-apple-request=1
hide-crashlytics-request=1
hide-udp=0
keyword-filter-type=(null)
keyword-filter=(null)

[Proxy]

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
allow-udp-proxy = true
bypass-tun = 10.0.0.0/8,100.64.0.0/10,127.0.0.0/8,169.254.0.0/16,172.16.0.0/12,192.0.0.0/24,192.0.2.0/24,192.88.99.0/24,192.168.0.0/16,198.18.0.0/15,198.51.100.0/24,203.0.113.0/24,224.0.0.0/4,255.255.255.255/32
dns-server = system,119.29.29.29,223.5.5.5
host = 127.0.0.1
skip-proxy = 192.168.0.0/16,10.0.0.0/8,172.16.0.0/12,localhost,*.local,e.crashlynatics.com

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
network_check_url=https://connectivitycheck.gstatic.com/generate_204
server_check_url=https://connectivitycheck.gstatic.com/generate_204

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
ipv6 = true
loglevel = notify
port = 8828
socks-port = 8829
wifi-access-http-port=8838
wifi-access-socks5-port=8839
interface = 0.0.0.0
socks-interface = 0.0.0.0
internet-test-url = https://connectivitycheck.gstatic.com/generate_204
proxy-test-url = https://connectivitycheck.gstatic.com/generate_204
test-timeout = 5

{% endif %}
{% if request.target == "sssub" %}
{
  "route": "bypass-lan-china",
  "remote_dns": "dns.google",
  "ipv6": true,
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

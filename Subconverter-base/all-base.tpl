{% if request.target == "clash" or request.target == "clashr" %}
mixed-port: {{ default(global.clash.mixed_port, "18888") }}
#redir-port: {{ default(global.clash.redir_port, "18890") }}
#authentication:
#  - "firefly:WJ960923"
allow-lan: {{ default(global.clash.allow_lan, "true") }}
bind-address: '*'
mode: rule
log-level: {{ default(global.clash.log_level, "info") }}
external-controller: {{ default(global.clash.api_port, "0.0.0.0:19090")}}
#external-ui: folder
secret: ''
routing-mark: {{ default(global.clash.routing_mark, "16666")}}
experimental:
  ignore-resolve-fail: true
  sniff-tls-sni: true
  udp-fallback-match: true
profile:
  store-fake-ip: true
  store-selected: true
  tracing: true
{% if exists("request.clash.dns") %}
{% if request.clash.dns == "tap" %}
ipv6: true
#interface-name: WLAN
dns:
  enable: true
  listen: 0.0.0.0:53
  ipv6: true
{% endif %}
{% if request.clash.dns == "win-tun" or request.clash.dns == "linux-tun" %}
ipv6: true
#interface-name: WLAN # conflict with `tun.auto-detect-interface`
tun:
  enable: true
  stack: system # or gvisor
  auto-route: true # manage `ip route` and `ip rules`
  auto-redir: true # manage nftable REDIRECT
  auto-detect-interface: true # auto detect interface, conflict with `interface-name`
  dns-hijack:
    - 22.0.0.1:53 # when `fake-ip-range` is 198.18.0.1/16, should hijack 198.18.0.2:53
    - any:53
auto-redir:
  enable: true
  auto-route: true
dns:
  enable: true
  listen: 0.0.0.0:6053
  ipv6: true
{% endif %}
{% if request.clash.dns == "meta-tun" %}
find-process-mode: strict
global-client-fingerprint: chrome
ipv6: true
tcp-concurrent: true
tun:
  enable: true
  stack: system # gvisor / lwip
  device: utun0
  dns-hijack:
    - any:53
  auto-detect-interface: true
  auto-route: true
  mtu: 9000
  strict_route: true
  inet4_route_address:
    - 0.0.0.0/1
    - 128.0.0.0/1
  inet6_route_address:
    - "::/1"
    - "8000::/1"
#interface-name: WLAN
sniffer:
  enable: true
  force-dns-mapping: true
  parse-pure-ip: true
  override-destination: true
  sniff:
    TLS:
      ports: [443, 8443]
    HTTP:
      ports: [80, 8080-8880]
      override-destination: true
#  force-domain:
#    - +.v2ex.com
  skip-domain:
     - Mijia Cloud
dns:
  enable: true
  prefer-h3: true
  ipv6: true
  ipv6-timeout: 150
  listen: 0.0.0.0:5053
{% endif %}
{% else %}
ipv6: true
#interface-name: WLAN
dns:
  enable: true
  listen: 0.0.0.0:1053
  ipv6: true
{% endif %}
  default-nameserver:
    - 223.5.5.5
    - 119.29.29.29
    - 1.1.1.1
  enhanced-mode: fake-ip # or redir-host (not recommended)
  fake-ip-range: 22.0.0.0/8
  fake-ip-filter:
    # === LAN ===
    - '*.example'
    - '*.home.arpa'
    - '*.invalid'
    - '*.lan'
    - '*.local'
    - '*.localdomain'
    - '*.localhost'
    - '*.test'
    # === Apple Software Update Service ===
    - 'mesu.apple.com'
    - 'swscan.apple.com'
    # === ASUS Router ===
    - '*.router.asus.com'
    # === Google ===
    - 'lens.l.google.com'
    - 'stun.l.google.com'
    ## Golang
    - 'proxy.golang.org'
    # === Linksys Wireless Router ===
    - '*.linksys.com'
    - '*.linksyssmartwifi.com'
    # === Windows 10 Connnect Detection ===
    - '*.ipv6.microsoft.com'
    - '*.msftconnecttest.com'
    - '*.msftncsi.com'
    - 'msftconnecttest.com'
    - 'msftncsi.com'
    # === NTP Service ===
    - 'ntp.*.com'
    - 'ntp1.*.com'
    - 'ntp2.*.com'
    - 'ntp3.*.com'
    - 'ntp4.*.com'
    - 'ntp5.*.com'
    - 'ntp6.*.com'
    - 'ntp7.*.com'
    - 'time.*.apple.com'
    - 'time.*.com'
    - 'time.*.gov'
    - 'time1.*.com'
    - 'time2.*.com'
    - 'time3.*.com'
    - 'time4.*.com'
    - 'time5.*.com'
    - 'time6.*.com'
    - 'time7.*.com'
    - 'time.*.edu.cn'
    - '*.time.edu.cn'
    - '*.ntp.org.cn'
    - '+.pool.ntp.org'
    - 'time1.cloud.tencent.com'
    # === Game Service ===
    ## Microsoft Xbox
    - 'speedtest.cros.wr.pvp.net'
    - '*.*.xboxlive.com'
    - 'xbox.*.*.microsoft.com'
    - 'xbox.*.microsoft.com'
    - 'xnotify.xboxlive.com'
    ## Nintendo Switch
    - '*.*.*.srv.nintendo.net'
    - '+.srv.nintendo.net'
    ## Sony PlayStation
    - '*.*.stun.playstation.net'
    - '+.stun.playstation.net'
    ## STUN Server
    - '+.stun.*.*.*.*'
    - '+.stun.*.*.*'
    - '+.stun.*.*'
    - 'stun.*.*.*'
    - 'stun.*.*'
    # === Music Service ===
    ## 咪咕音乐
    - '*.music.migu.cn'
    - 'music.migu.cn'
    ## 太和音乐
    - 'music.taihe.com'
    - 'musicapi.taihe.com'
    ## 腾讯音乐
    - 'songsearch.kugou.com'
    - 'trackercdn.kugou.com'
    - '*.kuwo.cn'
    - 'api-jooxtt.sanook.com'
    - 'api.joox.com'
    - 'joox.com'
    - 'y.qq.com'
    - '*.y.qq.com'
    - 'amobile.music.tc.qq.com'
    - 'aqqmusic.tc.qq.com'
    - 'mobileoc.music.tc.qq.com'
    - 'streamoc.music.tc.qq.com'
    - 'dl.stream.qqmusic.qq.com'
    - 'isure.stream.qqmusic.qq.com'
    ## 网易云音乐
    - 'music.163.com'
    - '*.music.163.com'
    - '*.126.net'
    ## 虾米音乐
    - '*.xiami.com'
    # === Other ===
    ## QQ Quick Login
    - 'localhost.ptlogin2.qq.com'
    - 'localhost.sec.qq.com'
    ## BiliBili P2P
    - '*.mcdn.bilivideo.cn'
  nameserver:
    - 223.5.5.5
    - 119.29.29.29
    - dhcp://system
    - https://dns.alidns.com/dns-query
    - https://doh.pub/dns-query
    - https://sm2.doh.pub/dns-query
    - https://dns.ipv6dns.com/dns-query
    - https://rubyfish.cn/dns-query
    - https://doh.mullvad.net/dns-query
    - https://unfiltered.adguard-dns.com/dns-query
#    - https://dns.twnic.tw/dns-query
#    - https://doh.opendns.com/dns-query
#    - https://cloudflare-dns.com/dns-query
#    - https://dns.google/dns-query
#    - https://dns.quad9.net/dns-query
#    - https://doh.qis.io/dns-query
#    - https://doh.powerdns.com/dns-query
#    - 101.101.101.101
#    - tcp://119.29.107.85:9090
#    - https://doh.sb/dns-query
#    - tls://cloudflare-dns.com:853
#    - tls://dns.google:853
#    - tls://dns-tls.qis.io:853
  fallback:
    - https://doh.sb/dns-query
    - https://dns.twnic.tw/dns-query
    - https://doh.opendns.com/dns-query
    - https://doh.mullvad.net/dns-query
    - https://dns.google/dns-query
    - https://dns.quad9.net/dns-query
#    - https://doh.qis.io/dns-query
#    - https://unfiltered.adguard-dns.com/dns-query
#    - https://cloudflare-dns.com/dns-query
#    - tcp://1.1.1.1
#    - https://dns.alidns.com/dns-query
#    - https://doh.sb/dns-query
#    - tls://cloudflare-dns.com:853
#    - tls://dns.google:853
#    - tls://dns-tls.qis.io:853
  fallback-filter:
#    geoip: true # default
#    geoip-code: CN
#    geosite:
#        - gfw
    ipcidr: # ips in these subnets will be considered polluted
      - 0.0.0.0/32
      - 100.64.0.0/10
      - 127.0.0.0/8
      - 240.0.0.0/4
      - 255.255.255.255/32

{% endif %}
{% if request.target == "surge" %}

[General]
allow-wifi-access = true
ipv6 = true
loglevel = notify
dns-server = system, 119.29.29.29, 223.5.5.5, 1.1.1.1, 1.0.0.1, 8.8.8.8, 8.8.4.4, 9.9.9.9:9953
doh-server = https://9.9.9.9/dns-query, https://dns.alidns.com/dns-query, https://i.233py.com/dns-query, https://doh.pub/dns-query, https://sm2.doh.pub/dns-query, https://dns.ipv6dns.com/dns-query, https://rubyfish.cn/dns-query, https://doh.mullvad.net/dns-query, https://doh.sb/dns-query, https://dns.twnic.tw/dns-query, https://doh.opendns.com/dns-query, https://dns.233py.com/dns-query, https://public.dns.iij.jp/dns-query, https://doh.mullvad.net/dns-query
hijack-dns = 8.8.8.8:53
tun-excluded-routes = 192.168.0.0/16, 10.0.0.0/8, 172.16.0.0/12
tun-included-routes = 192.168.1.12/32
always-real-ip = *.example, *.home.arpa, *.invalid, *.lan, *.local, *.localdomain, *.localhost, *.test, mesu.apple.com, swscan.apple.com, *.router.asus.com, lens.l.google.com, stun.l.google.com, proxy.golang.org, *.linksys.com, *.linksyssmartwifi.com, *.ipv6.microsoft.com, *.msftconnecttest.com, *.msftncsi.com, msftconnecttest.com, msftncsi.com, ntp.*.com, ntp1.*.com, ntp2.*.com, ntp3.*.com, ntp4.*.com, ntp5.*.com, ntp6.*.com, ntp7.*.com, time.*.apple.com, time.*.com, time.*.gov, time1.*.com, time2.*.com, time3.*.com, time4.*.com, time5.*.com, time6.*.com, time7.*.com, time.*.edu.cn, *.time.edu.cn, *.ntp.org.cn, +.pool.ntp.org, time1.cloud.tencent.com, speedtest.cros.wr.pvp.net, *.*.xboxlive.com, xbox.*.*.microsoft.com, xbox.*.microsoft.com, xnotify.xboxlive.com, *.*.*.srv.nintendo.net, +.srv.nintendo.net, *.*.stun.playstation.net, +.stun.playstation.net, +.stun.*.*.*.*, +.stun.*.*.*, +.stun.*.*, stun.*.*.*, stun.*.*, *.music.migu.cn, music.migu.cn, music.taihe.com, musicapi.taihe.com, songsearch.kugou.com, trackercdn.kugou.com, *.kuwo.cn, api-jooxtt.sanook.com, api.joox.com, joox.com, y.qq.com, *.y.qq.com, amobile.music.tc.qq.com, aqqmusic.tc.qq.com, mobileoc.music.tc.qq.com, streamoc.music.tc.qq.com, dl.stream.qqmusic.qq.com, isure.stream.qqmusic.qq.com, music.163.com, *.music.163.com, *.126.net, *.xiami.com, localhost.ptlogin2.qq.com, localhost.sec.qq.com, *.mcdn.bilivideo.cn
http-listen = 0.0.0.0:8829
socks5-listen = 0.0.0.0:8828
wifi-access-http-port = 8838
wifi-access-socks5-port = 8839
exclude-simple-hostnames = true
external-controller-access = 6170@0.0.0.0:6155
tls-provider = openssl
skip-proxy = 127.0.0.1, 192.168.0.0/16, 10.0.0.0/8, 172.16.0.0/12, 100.64.0.0/10, localhost, *.local
force-http-engine-hosts = 122.14.246.33, 175.102.178.52, mobile-api2011.elong.com
internet-test-url = http://connect.rom.miui.com/generate_204
proxy-test-url = http://connect.rom.miui.com/generate_204
test-timeout = 5

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
network_check_url=http://connect.rom.miui.com/generate_204
server_check_url=http://connect.rom.miui.com/generate_204

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
ipv6 = true
loglevel = notify
collapse-policy-group-items = true
dns-server = system, 119.29.29.29, 223.5.5.5, 1.1.1.1, 1.0.0.1, 8.8.8.8, 8.8.4.4, 9.9.9.9:9953
doh-server = https://9.9.9.9/dns-query, https://dns.alidns.com/dns-query, https://i.233py.com/dns-query, https://doh.pub/dns-query, https://sm2.doh.pub/dns-query, https://dns.ipv6dns.com/dns-query, https://rubyfish.cn/dns-query, https://doh.mullvad.net/dns-query, https://doh.sb/dns-query, https://dns.twnic.tw/dns-query, https://doh.opendns.com/dns-query, https://dns.233py.com/dns-query, https://public.dns.iij.jp/dns-query, https://doh.mullvad.net/dns-query
always-real-ip = *.example, *.home.arpa, *.invalid, *.lan, *.local, *.localdomain, *.localhost, *.test, mesu.apple.com, swscan.apple.com, *.router.asus.com, lens.l.google.com, stun.l.google.com, proxy.golang.org, *.linksys.com, *.linksyssmartwifi.com, *.ipv6.microsoft.com, *.msftconnecttest.com, *.msftncsi.com, msftconnecttest.com, msftncsi.com, ntp.*.com, ntp1.*.com, ntp2.*.com, ntp3.*.com, ntp4.*.com, ntp5.*.com, ntp6.*.com, ntp7.*.com, time.*.apple.com, time.*.com, time.*.gov, time1.*.com, time2.*.com, time3.*.com, time4.*.com, time5.*.com, time6.*.com, time7.*.com, time.*.edu.cn, *.time.edu.cn, *.ntp.org.cn, +.pool.ntp.org, time1.cloud.tencent.com, speedtest.cros.wr.pvp.net, *.*.xboxlive.com, xbox.*.*.microsoft.com, xbox.*.microsoft.com, xnotify.xboxlive.com, *.*.*.srv.nintendo.net, +.srv.nintendo.net, *.*.stun.playstation.net, +.stun.playstation.net, +.stun.*.*.*.*, +.stun.*.*.*, +.stun.*.*, stun.*.*.*, stun.*.*, *.music.migu.cn, music.migu.cn, music.taihe.com, musicapi.taihe.com, songsearch.kugou.com, trackercdn.kugou.com, *.kuwo.cn, api-jooxtt.sanook.com, api.joox.com, joox.com, y.qq.com, *.y.qq.com, amobile.music.tc.qq.com, aqqmusic.tc.qq.com, mobileoc.music.tc.qq.com, streamoc.music.tc.qq.com, dl.stream.qqmusic.qq.com, isure.stream.qqmusic.qq.com, music.163.com, *.music.163.com, *.126.net, *.xiami.com, localhost.ptlogin2.qq.com, localhost.sec.qq.com, *.mcdn.bilivideo.cn
enhanced-mode-by-rule = true
http-listen = 0.0.0.0:8829
socks5-listen = 0.0.0.0:8828
wifi-access-http-port=8838
wifi-access-socks5-port=8839
exclude-simple-hostnames = true
external-controller-access = surfboard@127.0.0.1:6170
skip-proxy = 127.0.0.1, 192.168.0.0/16, 10.0.0.0/8, 172.16.0.0/12, 100.64.0.0/10, localhost, *.local
udp-policy-not-supported-behaviour = REJECT
hide-crashlytics-request = false
internet-test-url = http://connect.rom.miui.com/generate_204
proxy-test-url = http://connect.rom.miui.com/generate_204
test-timeout = 5

[Host]
#abc.com = 1.2.3.4
#*.dev = 6.7.8.9
#foo.com = bar.com
#bar.com = server:8.8.8.8

[Proxy]

[Proxy Group]

[Rule]

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

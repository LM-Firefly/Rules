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
external-ui: /ui/xd/
#external-ui-name: xd
external-ui-url: "https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip"
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
#  auto-redir: true # manage nftable REDIRECT
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
ipv6: true
tun:
  enable: true
  stack: mixed # system/gvisor/mixed
  device: mihomo
  dns-hijack:
    - any:53
    - tcp://any:53
  auto-detect-interface: true
  auto-route: true
  mtu: 9000
  strict-route: true
  gso: true
  gso-max-size: 65536
  auto-redirect: true
  udp-timeout: 300
  route-address: # 启用 auto-route 时使用自定义路由而不是默认路由
    - 0.0.0.0/1
    - 128.0.0.0/1
    - "::/1"
    - "8000::/1"
  endpoint-independent-nat: false
#interface-name: WLAN
dns:
  cache-algorithm: arc
  enable: true
  prefer-h3: true
  listen: 0.0.0.0:5053
  ipv6: true
  ipv6-timeout: 150
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
    # === QQ Quick Login ===
    - 'localhost.ptlogin2.qq.com'
    - 'localhost.sec.qq.com'
    # === MiJia ===
    - 'Mijia Cloud'
    - '+.mijia.tech'
  fake-ip-filter-mode: blacklist
  nameserver:
    - 223.5.5.5
    - 119.29.29.29
    - dhcp://system
    - https://dns.alidns.com/dns-query
    - https://doh.pub/dns-query
    - https://dns.ipv6dns.com/dns-query
    - https://rubyfish.cn/dns-query
    - https://all.dns.mullvad.net/dns-query
    - https://unfiltered.adguard-dns.com/dns-query
#    - https://sm2.doh.pub/dns-query
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
    - https://cloudflare-dns.com/dns-query
    - https://dns.google/dns-query
    - https://doh.dns.sb/dns-query
    - https://dns.twnic.tw/dns-query
    - https://doh.opendns.com/dns-query
    - https://all.dns.mullvad.net/dns-query
    - https://dns.quad9.net/dns-query
#    - https://doh.sb/dns-query
#    - https://doh.qis.io/dns-query
#    - https://unfiltered.adguard-dns.com/dns-query
#    - tcp://1.1.1.1
#    - https://dns.alidns.com/dns-query
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
  use-system-hosts: false
sniffer:
  enable: true
  force-dns-mapping: true
  parse-pure-ip: true
  override-destination: true
  sniff:
    QUIC:
      ports: [443, 8443]
    TLS:
      ports: [443, 8443]
    HTTP:
      ports: [80, 8080-8880]
      override-destination: true
#  force-domain:
#    - +.v2ex.com
  skip-domain:
    - "Mijia Cloud"
    - +.mijia.tech
find-process-mode: strict
tcp-concurrent: true
global-client-fingerprint: chrome
keep-alive-interval: 30
unified-delay: true
# Clash for Android
clash-for-android:
  ui-subtitle-pattern: '[\u4e00-\u9fa5]{2,4}'

{% endif %}
{% if request.target == "surge" %}

[General]
allow-hotspot-access = true
allow-wifi-access = true
ipv6 = true
ipv6-vif = auto
loglevel = notify
bypass-system = true
bypass-tun = 22.0.0.0/8
dns-server = system, 119.29.29.29, 223.5.5.5, 1.1.1.1, 1.0.0.1, 8.8.8.8, 8.8.4.4, 9.9.9.9:9953
doh-server = https://dns.alidns.com/dns-query, https://dns.ipv6dns.com/dns-query, https://doh.pub/dns-query, https://rubyfish.cn/dns-query, https://all.dns.mullvad.net/dns-query, https://unfiltered.adguard-dns.com/dns-query, https://cloudflare-dns.com/dns-query, https://dns.google/dns-query, https://doh.dns.sb/dns-query, https://dns.twnic.tw/dns-query, https://doh.opendns.com/dns-query, https://dns.quad9.net/dns-query
doh-follow-outbound-mode = true
hijack-dns = *:53, 192.168.1.12:53, 8.8.8.8:53
tun-excluded-routes = 22.0.0.0/8
always-real-ip = *.example, *.home.arpa, *.invalid, *.lan, *.local, *.localdomain, *.localhost, *.test, mesu.apple.com, swscan.apple.com, *.router.asus.com, lens.l.google.com, stun.l.google.com, proxy.golang.org, *.linksys.com, *.linksyssmartwifi.com, *.ipv6.microsoft.com, *.msftconnecttest.com, *.msftncsi.com, msftconnecttest.com, msftncsi.com, ntp.*.com, ntp1.*.com, ntp2.*.com, ntp3.*.com, ntp4.*.com, ntp5.*.com, ntp6.*.com, ntp7.*.com, time.*.apple.com, time.*.com, time.*.gov, time1.*.com, time2.*.com, time3.*.com, time4.*.com, time5.*.com, time6.*.com, time7.*.com, time.*.edu.cn, *.time.edu.cn, *.ntp.org.cn, +.pool.ntp.org, time1.cloud.tencent.com, speedtest.cros.wr.pvp.net, *.*.xboxlive.com, xbox.*.*.microsoft.com, xbox.*.microsoft.com, xnotify.xboxlive.com, *.music.migu.cn, music.migu.cn, music.taihe.com, musicapi.taihe.com, songsearch.kugou.com, trackercdn.kugou.com, *.kuwo.cn, api-jooxtt.sanook.com, api.joox.com, joox.com, y.qq.com, *.y.qq.com, amobile.music.tc.qq.com, aqqmusic.tc.qq.com, mobileoc.music.tc.qq.com, streamoc.music.tc.qq.com, dl.stream.qqmusic.qq.com, isure.stream.qqmusic.qq.com, music.163.com, *.music.163.com, *.126.net, *.xiami.com, localhost.ptlogin2.qq.com, localhost.sec.qq.com, *.mcdn.bilivideo.cn
http-listen = 0.0.0.0:8829
socks5-listen = 0.0.0.0:8828
wifi-access-http-port = 8838
wifi-access-socks5-port = 8839
http-api = 6170@0.0.0.0:6166
http-api-web-dashboard = true
exclude-simple-hostnames = true
external-controller-access = 6170@0.0.0.0:6155
tls-provider = openssl
# skip-proxy = 127.0.0.0/8, 192.168.0.0/16, 10.0.0.0/8, 172.16.0.0/12, 100.64.0.0/10, localhost, *.local
force-http-engine-hosts = 122.14.246.33, 175.102.178.52, mobile-api2011.elong.com
internet-test-url = https://www.google-analytics.com/generate_204
proxy-test-url = https://www.google-analytics.com/generate_204
test-timeout = 5
hide-vpn-icon = true
read-etc-hosts = true
udp-policy-not-supported-behaviour = REJECT

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
ipv6 = true
allow-wifi-access = true
wifi-access-http-port = 18888
wifi-access-socks5-port = 18889
allow-udp-proxy = true
bypass-tun = 22.0.0.0/8
dns-server = system, 119.29.29.29, 223.5.5.5, 1.1.1.1, 1.0.0.1, 8.8.8.8, 8.8.4.4, 9.9.9.9:9953
doh-server = https://dns.alidns.com/dns-query, https://dns.ipv6dns.com/dns-query, https://doh.pub/dns-query, https://rubyfish.cn/dns-query, https://all.dns.mullvad.net/dns-query, https://unfiltered.adguard-dns.com/dns-query, https://cloudflare-dns.com/dns-query, https://dns.google/dns-query, https://doh.dns.sb/dns-query, https://dns.twnic.tw/dns-query, https://doh.opendns.com/dns-query, https://dns.quad9.net/dns-query
host = 127.0.0.1
proxy-test-url = https://www.google-analytics.com/generate_204
# skip-proxy = 127.0.0.0/8, 192.168.0.0/16, 10.0.0.0/8, 172.16.0.0/12, 100.64.0.0/10, localhost, *.local
test-timeout = 2
interface-mode = auto
sni-sniffing = true
disable-stun = true
disconnect-on-policy-change = true
switch-node-after-failure-times = 3
resource-parser = https://gitlab.com/lodepuly/vpn_tool/-/raw/main/Resource/Script/Sub-Store/sub-store-parser_for_loon.js
geoip-url = https://gitlab.com/Masaiki/GeoIP2-CN/-/raw/release/Country.mmdb
ssid-trigger = "Ccccccc":DIRECT,"cellular":RULE,"default":RULE

[Proxy]

[Remote Proxy]

[Remote Filter]

[Proxy Group]

[Rule]

[Remote Rule]

[Rewrite]
enable = true
^https?:\/\/(www.)?(g|google)\.cn https://www.google.com 302

[Host]

[Script]
# 多看阅读  (By @chavyleung)
# 我的 > 签到任务 等到提示获取 Cookie 成功即可
http-request ^https:\/\/www\.duokan\.com\/checkin\/v0\/status script-path=https://raw.githubusercontent.com/chavyleung/scripts/master/duokan/duokan.cookie.js, requires-body=true, tag=多看_cookie
cron "16 9 * * *" script-path=https://raw.githubusercontent.com/chavyleung/scripts/master/duokan/duokan.js, tag=多看阅读

# 飞客茶馆  (By @chavyleung)
# 打开 APP, 访问下个人中心
http-request ^https:\/\/www\.flyertea\.com\/source\/plugin\/mobile\/mobile\.php\?module=getdata&.* script-path=https://raw.githubusercontent.com/chavyleung/scripts/master/flyertea/flyertea.cookie.js, tag=飞客茶馆_cookie
cron "17 9 * * * *" script-path=https://raw.githubusercontent.com/chavyleung/scripts/master/flyertea/flyertea.js,tag=飞客茶馆

# 10010  (By @chavyleung)
# 打开 APP , 进入签到页面, 系统提示: 获取刷新链接: 成功
# 然后手动签到 1 次, 系统提示: 获取Cookie: 成功 (每日签到)
# 首页>天天抽奖, 系统提示 2 次: 获取Cookie: 成功 (登录抽奖) 和 获取Cookie: 成功 (抽奖次数)
http-request ^https?:\/\/act.10010.com\/SigninApp\/signin\/querySigninActivity.htm script-path=https://raw.githubusercontent.com/chavyleung/scripts/master/10010/10010.cookie.js, tag=中国联通_cookie1
http-request ^https?:\/\/act.10010.com\/SigninApp(.*?)\/signin\/daySign script-path=https://raw.githubusercontent.com/chavyleung/scripts/master/10010/10010.cookie.js, tag=中国联通_cookie2
http-request ^https?:\/\/m.client.10010.com\/dailylottery\/static\/(textdl\/userLogin|active\/findActivityInfo) script-path=https://raw.githubusercontent.com/chavyleung/scripts/master/10010/10010.cookie.js, tag=中国联通_cookie3
cron "18 9 * * *" script-path=https://raw.githubusercontent.com/chavyleung/scripts/master/10010/10010.js, tag=中国联通

# 万达电影  (By @chavyleung)
# 进入签到页面获取，网页端:https://act-m.wandacinemas.com/2005/17621a8caacc4d190dadd/
http-request ^https:\/\/user-api-prd-mx\.wandafilm\.com script-path=https://raw.githubusercontent.com/chavyleung/scripts/master/wanda/wanda.cookie.js, tag=万达电影_cookie
cron "19 9 * * *" script-path=https://raw.githubusercontent.com/chavyleung/scripts/master/wanda/wanda.js, tag=万达电影

[MITM]
hostname = m.client.10010.com, act.10010.com, www.flyertea.com, www.duokan.com, tieba.baidu.com
ca-p12 = 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
ca-passphrase = FA1A9849
skip-server-cert-verify = false

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
network_check_url=https://www.google-analytics.com/generate_204
server_check_url=https://www.google-analytics.com/generate_204

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
doh-server = https://dns.alidns.com/dns-query, https://dns.ipv6dns.com/dns-query, https://doh.pub/dns-query, https://rubyfish.cn/dns-query, https://all.dns.mullvad.net/dns-query, https://unfiltered.adguard-dns.com/dns-query, https://cloudflare-dns.com/dns-query, https://dns.google/dns-query, https://doh.dns.sb/dns-query, https://dns.twnic.tw/dns-query, https://doh.opendns.com/dns-query, https://dns.quad9.net/dns-query
always-real-ip = *.example, *.home.arpa, *.invalid, *.lan, *.local, *.localdomain, *.localhost, *.test, mesu.apple.com, swscan.apple.com, *.router.asus.com, lens.l.google.com, stun.l.google.com, proxy.golang.org, *.linksys.com, *.linksyssmartwifi.com, *.ipv6.microsoft.com, *.msftconnecttest.com, *.msftncsi.com, msftconnecttest.com, msftncsi.com, ntp.*.com, ntp1.*.com, ntp2.*.com, ntp3.*.com, ntp4.*.com, ntp5.*.com, ntp6.*.com, ntp7.*.com, time.*.apple.com, time.*.com, time.*.gov, time1.*.com, time2.*.com, time3.*.com, time4.*.com, time5.*.com, time6.*.com, time7.*.com, time.*.edu.cn, *.time.edu.cn, *.ntp.org.cn, +.pool.ntp.org, time1.cloud.tencent.com, speedtest.cros.wr.pvp.net, *.*.xboxlive.com, xbox.*.*.microsoft.com, xbox.*.microsoft.com, xnotify.xboxlive.com, *.music.migu.cn, music.migu.cn, music.taihe.com, musicapi.taihe.com, songsearch.kugou.com, trackercdn.kugou.com, *.kuwo.cn, api-jooxtt.sanook.com, api.joox.com, joox.com, y.qq.com, *.y.qq.com, amobile.music.tc.qq.com, aqqmusic.tc.qq.com, mobileoc.music.tc.qq.com, streamoc.music.tc.qq.com, dl.stream.qqmusic.qq.com, isure.stream.qqmusic.qq.com, music.163.com, *.music.163.com, *.126.net, *.xiami.com, localhost.ptlogin2.qq.com, localhost.sec.qq.com, *.mcdn.bilivideo.cn
enhanced-mode-by-rule = true
http-listen = 0.0.0.0:8829
socks5-listen = 0.0.0.0:8828
wifi-access-http-port=8838
wifi-access-socks5-port=8839
exclude-simple-hostnames = true
external-controller-access = surfboard@0.0.0.0:6170
# skip-proxy = 127.0.0.0/8, 192.168.0.0/16, 10.0.0.0/8, 172.16.0.0/12, 100.64.0.0/10, localhost, *.local
udp-policy-not-supported-behaviour = REJECT
hide-crashlytics-request = false
internet-test-url = https://www.google-analytics.com/generate_204
proxy-test-url = https://www.google-analytics.com/generate_204
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
{% if request.target == "singbox" %}

{
  "log": { "disabled": false, "level": "info", "output": "box.log", "timestamp": true },
  "dns": {
    "servers": [
      {
        "type": "fakeip",
        "tag": "fakeip",
        "inet4_range": "28.0.0.0/8",
        "inet6_range": "fc00::/18"
      },
      {
        "type": "tls",
        "tag": "local",
        "server": "tls://223.5.5.5",
        "server_port": 853,
        "detour": "DIRECT"
      },
      {
        "type": "tls",
        "tag": "proxy",
        "server": "tls://1.1.1.1",
        "server_port": 853,
        "detour": "proxy"
      }
    ],
    "rules": [
      {
        "query_type": ["A", "AAAA"],
        "server": "fakeip"
      },
      {
        "rule_set": "geoip-cn",
        "clash_mode": "rule",
        "action": "route",
        "server": "local"
      },
      {
        "rule_set": "geoip-cn",
        "invert": true,
        "clash_mode": "rule",
        "action": "route",
        "server": "proxy"
      }
    ],
    "final": "",
    "strategy": "prefer_ipv4"
  },
  "ntp": {
    "enabled": true,
    "server": "time.apple.com",
    "server_port": 123,
    "interval": "30m",
    "detour": "local"
  },
  "certificate": {},
  "endpoints": [],
  "inbounds": [
    {
      "type": "tun",
      "tag": "tun-in",
      "interface_name": "singtun",
      "address": ["28.0.0.1/30", "fdfe:dcba:9876::1/126"],
      "mtu": 9000,
      "auto_route": true,
      "iproute2_table_index": 2022,
      "iproute2_rule_index": 9000,
      "auto_redirect": false,
      "auto_redirect_input_mark": "0x2023",
      "auto_redirect_output_mark": "0x2024",
      "strict_route": true,
      "route_address": ["0.0.0.0/1", "128.0.0.0/1", "::/1", "8000::/1"],
      "endpoint_independent_nat": false,
      "udp_timeout": "5m",
      "stack": "system",
      "platform": {
        "http_proxy": {
          "enabled": false,
          "server": "127.0.0.1",
          "server_port": 18888
        }
      },
      "listen": "::",
      "listen_port": 18888,
      "tcp_fast_open": true,
      "tcp_multi_path": false,
      "udp_fragment": false
    }
  ],
  "outbounds": [],
  "route": {
    "rules": [
      {
        "ip_is_private": true,
        "outbound": "direct"
      },
      {
        "rule_set": "geoip-cn",
        "outbound": "direct"
      }
    ],
    "rule_set": [
      {
        "tag": "geoip-cn",
        "type": "remote",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set/geoip-cn.srs",
        "download_detour": "proxy"
      }
    ]
  },
  "experimental": {
    "cache_file": {
      "enabled": true,
      "path": "cache.db",
      "cache_id": "",
      "store_fakeip": true,
      "store_rdrc": true,
      "rdrc_timeout": ""
    },
    "clash_api": {
      "external_controller": "127.0.0.1:19090",
      "external_ui": "",
      "external_ui_download_url": "",
      "external_ui_download_detour": "proxy",
      "secret": "",
      "default_mode": "rule",
      "access_control_allow_origin": [],
      "access_control_allow_private_network": false
    },
    "v2ray_api": {}
  }
}

{% endif %}

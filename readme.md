# Rules

自用 Clash 规则集

| 文件名                | 包含内容                                                              |
| --------------------- | --------------------------------------------------------------------- |
| DNS.list              | 常用 DNS                                                              |
| NTP-service.list      | 常见 NTP 服务列表，路由器可能需要加入 fake-ip-filter                  |
| Adblock.list          | 常见广告域名（广告联盟 等）                                           |
| Super-Block.list      | 超级广告列表，取自 EnergizedProtection 广告域名，误杀严重，不建议使用 |
| Apple.list            | 苹果公司服务                                                          |
| BiliBili.list         | 哔哩哔哩                                                              |
| Domestic.list         | 中国大陆常见公司服务                                                  |
| TeamViewer-CIDR.list  | TeamViewer 远程 IP 段 需要直连 才能远程                               |
| Netease.list          | 网易公司服务                                                          |
| LAN-Special-Apps.list | 局域网特殊应用域名（投屏、广播 等）                                   |
| Video-Crack.list      | 盗版视频解析站                                                        |
| Xiaomi.list           | 小米公司服务                                                          |
| DMCA-Sensitive.list   | DMCA 敏感域名（主要针对机场审计 tracker、迅雷）                       |
| GlobalMedia.list      | 国外常见流媒体服务                                                    |
| Google.list           | Google 服务                                                           |
| iQIYI.list            | 爱奇艺服务                                                            |
| LineTV.ist            | LineTV 服务                                                           |
| Microsoft.list        | 微软服务                                                              |
| Netflix.list          | Netflix 流媒体服务                                                    |
| Telegram.list         | Telegram 服务                                                         |
| Twitch.list           | Twitch 直播服务                                                       |
| PROXY.list            | 常见国外服务                                                          |
| CCC-CN.list           | 中国常见 云计算公司                                                   |
| CCC-Global.list       | 全球常见 云计算公司                                                   |
| Alibaba.list          | 阿里巴巴服务                                                          |
| SpeedTest.list        | Ookla SpeedTest 服务器                                                |
| Local-LAN.list        | 局域网 IP 段                                                          |

须知:
Domestic-Services | Global-Services 只是作为引用小切片列出, 与 Domestic.list | GlobalMedia.list 并非相互对映，具体包含关系以列表注释为准。

相关引用:
[EnergizedProtection](https://github.com/EnergizedProtection/block/tree/master/extensions/regional) | [Telegram CIDR](https://core.telegram.org/resources/cidr.txt)

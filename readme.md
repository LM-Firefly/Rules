## Rules

### 自用 Clash 规则集

| 文件名                | 包含内容                                                                                                 |
| --------------------- | -------------------------------------------------------------------------------------------------------- |
| DNS.list              | 常用 DNS                                                                                                 |
| NTP-service.list      | 常见 NTP 服务列表，路由器可能需要加入 fake-ip-filter                                                     |
| Adblock.list          | 常见广告域名（广告联盟 等）                                                                              |
| Apple.list            | 苹果公司服务, 详见 [Apple.md](https://github.com/LM-Firefly/Rules/blob/master/Apple.md)                  |
| Domestic.list         | 中国大陆常见公司服务                                                                                     |
| TeamViewer-CIDR.list  | TeamViewer 远程 IP 段 需要直连 才能远程                                                                  |
| LAN-Special-Apps.list | 局域网特殊应用域名（投屏、广播 等）                                                                      |
| Video-Crack.list      | 盗版视频解析站                                                                                           |
| DMCA-Sensitive.list   | DMCA 敏感域名（主要针对机场审计 tracker、迅雷）                                                          |
| Game.list             | 游戏平台, 详见 [Game.md](https://github.com/LM-Firefly/Rules/blob/master/Game.md)                        |
| GlobalMedia.list      | 国外常见流媒体服务,详见 [GlobalMedia.md](https://github.com/LM-Firefly/Rules/blob/master/GlobalMedia.md) |
| Google.list           | Google 服务                                                                                              |
| Microsoft.list        | 微软服务                                                                                                 |
| PROXY.list            | 常见国外服务                                                                                             |
| CCC-CN.list           | 中国常见 云计算公司                                                                                      |
| CCC-Global.list       | 全球常见 云计算公司                                                                                      |
| SpeedTest.list        | Ookla SpeedTest 服务器                                                                                   |
| Local-LAN.list        | 局域网 IP 段                                                                                             |

### 须知:

[Domestic-Services](https://github.com/LM-Firefly/Rules/tree/master/Domestic-Services) | [Global-Services](https://github.com/LM-Firefly/Rules/tree/master/Global-Services) 只是作为引用小切片列出, 与 [Domestic.list](https://github.com/LM-Firefly/Rules/blob/master/Domestic.list) | [GlobalMedia.list](https://github.com/LM-Firefly/Rules/blob/master/GlobalMedia.list) 并非相互对映，具体包含关系以列表注释为准。

### 灵活转换:

如果有特殊格式需要，可以尝试使用 [Subconverter](https://github.com/tindy2013/subconverter/blob/master/README-cn.md#%E8%A7%84%E5%88%99%E8%BD%AC%E6%8D%A2) 自行转换，有很多公共的免费服务可以白嫖。这里提供一个我的后端，render 白嫖的 [firefly-subs.onrender.com](https://firefly-subs.onrender.com/)。

### 相关引用:

[Telegram CIDR](https://core.telegram.org/resources/cidr.txt)

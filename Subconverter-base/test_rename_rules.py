#!/usr/bin/env python3
"""
Test script to validate `node_pref.rename_node` rules in `AllSub-AdBlock.toml`.

Usage: python test_rename_rules.py [--toml PATH] [--cases PATH]

It parses the TOML file, extracts all rename rules, and sequentially applies them
to the provided test cases, printing transformations and the applied rules.
"""
from __future__ import annotations
import argparse
import json
import os
import sys
import codecs
try:
    import tomllib  # Python 3.11+
except Exception:
    try:
        import tomli as tomllib
    except Exception:
        tomllib = None

def _ensure_regex_package():
    """Ensure `regex` package is available and imported as `re`.

    Tries to import `regex` first; if missing, attempts to install it via
    `python -m pip install regex` and re-import. Falls back to builtin `re`
    with a clear warning if installation/import fails.
    """
    import importlib
    try:
        regex = importlib.import_module('regex')
        return regex
    except Exception:
        # Try to install it via pip
        import subprocess
        import sys
        print('`regex` package not found; attempting to install via pip...')
        try:
            subprocess.check_call([sys.executable, '-m', 'pip', 'install', 'regex'])
        except Exception as e:
            print(f'Failed to install `regex` via pip: {e}')
            print('Falling back to builtin `re` (may lack Unicode/PCRE features).')
            import re as _re
            return _re
        else:
            # Try to import again
            try:
                regex = importlib.import_module('regex')
                print('`regex` installed and imported successfully.')
                return regex
            except Exception as e:
                print(f'Installed `regex` but failed to import: {e}')
                print('Falling back to builtin `re` (may lack Unicode/PCRE features).')
                import re as _re
                return _re


# Prefer the third-party `regex` module for full Unicode/PCRE behavior.
re = _ensure_regex_package()
# Helpful diagnostic: print which regex engine will be used
try:
    mod_name = getattr(re, '__name__', type(re).__name__)
    ver = getattr(re, '__version__', None)
    if ver:
        print(f'Using regex engine: {mod_name} {ver}')
    else:
        print(f'Using regex engine: {mod_name}')
except Exception:
    print('Using regex engine: unknown')


DEFAULT_TOML = os.path.join(os.path.dirname(__file__), "AllSub-AdBlock.toml")
DEFAULT_OUT = os.path.join(os.path.dirname(__file__), "results.json")

# Default cases provided by user attachment
cases = [
    '☠️ [境外用户专用]GPT01',
    '☠️ ‍☠️ 未知地区 | Unknown 2',
    '☠️ ❓Other_1 | ⬇️ 6.7MB/s',
    '☠️ 🌐|UN|@wxgqlfx|17',
    '☠️ 2-nkxiuhrq',
    '☠️ 未知地区 | Unknown 10',
    '☠️ 未知地区 | Unknown 2',
    '☠️ 未知地区 | Unknown 20',
    '☠️ 未知地区 | Unknown 3',
    '☠️ 未知地区 | Unknown',
    '☠️ Channel: https://t.me/txwl666',
    '☠️ Group: https://t.me/txwl233',
    '☠️ jija1-50zeloua',
    '☠️ jija1-Daniil',
    '☠️ jija1-jija',
    '☠️ jija1-Katya',
    '☠️ jija1-Olga',
    '☠️ jija1-Sonya',
    '☠️ jija1-Zinaida',
    '☠️ LinuxDo@ZSF-17',
    '☠️ LinuxDo@ZSF-3',
    '☠️ sufujia.top',
    '☠️ v2zt06d6',
    '☠️ VLESS с XTLS-Reality-@AlexandraKra',
    '☠️ VLESS с XTLS-Reality-@Asya_epilstar',
    '☠️ VLESS с XTLS-Reality-@belochkinaaa',
    '☠️ VLESS с XTLS-Reality-@julia_musurina',
    '☠️ VLESS с XTLS-Reality-@mr_chizh',
    '☠️ VLESS с XTLS-Reality-Dnevnik_GM1',
    '☠️ VLESS с XTLS-Reality-Dnevnik_GM2',
    '☠️ VLESS с XTLS-Reality-mom',
    '☠️ VLESS с XTLS-Reality-Ya',
    '☠️ VLESS с XTLS-Reality-Ya1',
    '☠️ VPN-Anton Nout',
    '☠️ VPN-Anton',
    '☠️ VPN-Olya Nout',
    '☠️ VPN-Olya',
    '♥流量:10620.7GB 等级6剩:1512.6天',
    '🇦🇪 阿联酋 | ARE',
    '🇦🇷 [AR]阿根廷-BuenosAires',
    '🇦🇺 [AU]澳大利亚-Sydney',
    '🇦🇺 |AU|@wxgqlfx|70',
    '🇦🇺 澳大利亚 | AUS 10',
    '🇦🇺 澳大利亚 | AUS 2',
    '🇦🇺 澳大利亚 | AUS 20',
    '🇦🇺 澳大利亚 | AUS 3',
    '🇦🇺 澳大利亚 | AUS',
    '🇦🇺 澳大利亚 01',
    '🇦🇺 澳大利亚 02',
    '🇦🇺 澳大利亚原生1-1A',
    '🇦🇺 澳大利亚原生2-1A',
    '🇦🇺 悉尼大陆优化BGP线路',
    '🇧🇷 巴西 | BRA 2',
    '🇧🇷 巴西 | BRA',
    '🇧🇷 巴西 01',
    '🇧🇷 BR_2 | ⬇️ 5.3MB/s',
    '🇨🇦 [CA]加拿大-Toronto',
    '🇨🇦 加拿大 | CAN 10',
    '🇨🇦 加拿大 | CAN 2',
    '🇨🇦 加拿大 | CAN 20',
    '🇨🇦 加拿大 | CAN 3',
    '🇨🇦 加拿大 | CAN',
    '🇨🇦 加拿大 09',
    '🇨🇦 加拿大 10',
    '🇨🇦 加拿大1-1A',
    '🇨🇦 加拿大2-1A',
    '🇨🇦 CA_1 | ⬇️ 7.1MB/s',
    '🇨🇭 瑞士 | CHE',
    '🇨🇴 哥伦比亚 | COL',
    '🇩🇪 [DE]德国-Frankfurt01',
    '🇩🇪 |DE|@wxgqlfx|73',
    '🇩🇪 德国 | DEU 10',
    '🇩🇪 德国 | DEU 2',
    '🇩🇪 德国 | DEU',
    '🇩🇪 德国 07',
    '🇩🇪 德国 20',
    '🇩🇪 德国-V6|01 0.5x',
    '🇩🇪 德国4',
    '🇩🇪 de v6',
    '🇩🇪 DE_1 | ⬇️ 7.5MB/s',
    '🇩🇪 DE_22 | ⬇️ 4.4MB/s',
    '🇩🇪 DE_3 | ⬇️ 5.6MB/s',
    '🇩🇰 丹麦 | DNK',
    '🇪🇪 |EE|@wxgqlfx|50',
    '🇪🇸 西班牙 | ESP',
    '🇫🇮 芬兰 | FIN 2',
    '🇫🇮 芬兰 | FIN',
    '🇫🇮 芬兰 01',
    '🇫🇮 FI_1 | ⬇️ 4.3MB/s',
    '🇫🇮 FI_2 | ⬇️ 2.4MB/s',
    '🇫🇷 [FR]法国-Paris01',
    '🇫🇷 |FR|@wxgqlfx|72',
    '🇫🇷 法国 | FRA 10',
    '🇫🇷 法国 | FRA 2',
    '🇫🇷 法国 | FRA',
    '🇫🇷 法国 01',
    '🇫🇷 法国1-1A',
    '🇫🇷 法国1',
    '🇫🇷 法国2-1A',
    '🇫🇷 FR_3 | ⬇️ 4.7MB/s',
    '🇬🇧 [UK]英国Coventry01-BBC优化',
    '🇬🇧 英国 | GBR 2',
    '🇬🇧 英国 | GBR',
    '🇬🇧 英国 05',
    '🇬🇧 英国1-1A',
    '🇬🇧 英国2-1A',
    '🇬🇧 GB DIGITALOCEAN 03',
    '🇬🇧 GB_speednode_0009',
    '🇬🇧 KX ipv6@dingyue_Center',
    '🇭🇰 [CN]HK专线01-【5倍率】',
    '🇭🇰 [HK]HongKong01-GPT优化',
    '🇭🇰 [HK]HongKong10-GPT优化',
    '🇭🇰 三网优化无限流@10Mbps',
    '🇭🇰 香港 | HKG 10',
    '🇭🇰 香港 | HKG 2',
    '🇭🇰 香港 | HKG 20',
    '🇭🇰 香港 | HKG',
    '🇭🇰 香港 06',
    '🇭🇰 香港-V6|05 0.5x',
    '🇭🇰 香港-V6|06',
    '🇭🇰 香港1',
    '🇭🇰 香港高速1',
    '🇭🇰 香港节点',
    '🇭🇰 香港NO.2-1A',
    '🇭🇰 HK_1 | ⬇️ 5.1MB/s',
    '🇭🇰 Salm CMv 4T',
    '🇭🇰 Salm CMv4 1T-4号',
    '🇭🇰 wawo ipv6',
    '🇭🇰 Yoo 2T2号',
    '🇭🇰 Yoo CF 2T 40M/s',
    '🇭🇰 Zouter@1Gbps',
    '🇭🇰香港精品31',
    '🇮🇪 爱尔兰 | IRL 10',
    '🇮🇪 爱尔兰 | IRL 2',
    '🇮🇪 爱尔兰 | IRL',
    '🇮🇪 爱尔兰 01',
    '🇮🇪 暂停准备cf 6TB',
    '🇮🇱 以色列 | ISR 2',
    '🇮🇱 以色列 | ISR',
    '🇮🇱 IL AS 01',
    '🇮🇱 IL_1 | ⬇️ 3.8MB/s',
    '🇮🇳 [IN]印度-bangalore',
    '🇮🇳 印度 | IND 10',
    '🇮🇳 印度 | IND 2',
    '🇮🇳 印度 | IND',
    '🇮🇳 印度 06',
    '🇮🇳 印度1-1A',
    '🇮🇳 印度2-1A',
    '🇮🇹 意大利 | ITA',
    '🇯🇵 [JP]Tokyo01',
    '🇯🇵 [JP]Tokyo10',
    '🇯🇵 日本 | JPN 10',
    '🇯🇵 日本 | JPN 2',
    '🇯🇵 日本 | JPN 20',
    '🇯🇵 日本 | JPN 3',
    '🇯🇵 日本 | JPN',
    '🇯🇵 日本 04',
    '🇯🇵 日本-V6|02',
    '🇯🇵 日本',
    '🇯🇵 日本节点',
    '🇯🇵 日本四 isp 解锁openai',
    '🇯🇵 日本NO.1-1A',
    '🇯🇵 日本NO.2-1A',
    '🇯🇵 JP BAGE 07',
    '🇯🇵 JP NTT 05',
    '🇯🇵 JP-IDC-NODE1',
    '🇯🇵 No.517_[JP]\U0001F9EAisif_x1.0_1000M_日本/CTGGIA/9929/CMIN2/解锁Netflix/',
    '🇰🇷 [KR]韩国-Seoul',
    '🇰🇷 韩国 | KOR 10',
    '🇰🇷 韩国 | KOR 2',
    '🇰🇷 韩国 | KOR 20',
    '🇰🇷 韩国 | KOR 3',
    '🇰🇷 韩国 | KOR',
    '🇰🇷 韩国 01',
    '🇰🇷 韩国 专线NO1-1A',
    '🇰🇷 韩国 专线NO2-1A',
    '🇰🇷 韩国',
    '🇰🇷 韩国节点',
    '🇰🇷 KR_1 | ⬇️ 3.9MB/s',
    '🇲🇰 [MK]马其顿-Macedonia',
    '🇲🇾 |MY|@wxgqlfx|53',
    '🇲🇾 马来西亚 | MYS 2',
    '🇲🇾 马来西亚 | MYS',
    '🇳🇬 [NG]尼日利亚-Lagos',
    '🇳🇱 [NL]荷兰-Amsterdam',
    '🇳🇱 荷兰 | NLD 2',
    '🇳🇱 荷兰 | NLD',
    '🇳🇱 荷兰 03',
    '🇳🇱 荷兰-V6|01 0.5x',
    '🇳🇱 荷兰6',
    '🇳🇱 NL_2 | ⬇️ 9.0MB/s',
    '🇳🇱 NL_3 | ⬇️ 4.0MB/s',
    '🇵🇱 波兰 01',
    '🇵🇱 PL_1 | ⬇️ 6.2MB/s',
    '🇵🇱 PL_2 | ⬇️ 2.8MB/s',
    '🇵🇹 葡萄牙 | PRT 2',
    '🇵🇹 葡萄牙 | PRT',
    '🇵🇹 葡萄牙 01',
    '🇷🇺 [RU]俄罗斯-Moscow',
    '🇷🇺 |RU|@wxgqlfx|41',
    '🇷🇺 俄罗斯 | RUS 2',
    '🇷🇺 俄罗斯 | RUS',
    '🇷🇺 RU_1 | ⬇️ 5.9MB/s',
    '🇷🇺 RU_2 | ⬇️ 6.2MB/s',
    '🇸🇪 斯德哥尔摩',
    '🇸🇬 [CN]SG专线01-【5倍率】',
    '🇸🇬 [SG]Singapore01',
    '🇸🇬 免费-新加坡1',
    '🇸🇬 狮城节点',
    '🇸🇬 新加坡 | SGP 2',
    '🇸🇬 新加坡 | SGP',
    '🇸🇬 新加坡 01',
    '🇸🇬 新加坡',
    '🇸🇬 新加坡NO.1-1A',
    '🇸🇬 新加坡NO.2-1A',
    '🇸🇬 SG AMAZON 03',
    '🇸🇬 SG_1 | ⬇️ 6.7MB/s',
    '🇸🇬 sg-v4',
    '🇸🇬 Tencent SG 无限流量',
    '🇹🇭 泰国 | THA',
    '🇹🇷 [TR]土耳其-Istanbul',
    '🇹🇷 土耳其 | TUR 2',
    '🇹🇷 土耳其 | TUR',
    '🇹🇼 [CN]TW专线01-【5倍率】',
    '🇹🇼 [TW]TaiPei01-GPT优化',
    '🇹🇼 台湾 | TWN 10',
    '🇹🇼 台湾 | TWN 2',
    '🇹🇼 台湾 | TWN',
    '🇹🇼 台湾 02',
    '🇹🇼 台湾',
    '🇹🇼 台湾1-1A',
    '🇹🇼 台湾2-1A',
    '🇹🇼 台湾家宽 02',
    '🇹🇼 台湾节点',
    '🇹🇼 tw home dialer',
    '🇺🇸 [US]美国Los Angeles01-GPT优化',
    '🇺🇸 [US]美国San Francisco09-GPT优化',
    '🇺🇸 [US]美国San Jose07-GPT优化',
    '🇺🇸 [US]美国Santa Clara05-GPT优化',
    '🇺🇸 哈基猫500G@300M CF',
    '🇺🇸 美国 | USA 10',
    '🇺🇸 美国 | USA 2',
    '🇺🇸 美国 | USA 20',
    '🇺🇸 美国 | USA 3',
    '🇺🇸 美国 | USA 30',
    '🇺🇸 美国 | USA 4',
    '🇺🇸 美国 | USA 40',
    '🇺🇸 美国 | USA 5',
    '🇺🇸 美国 | USA 50',
    '🇺🇸 美国 | USA 6',
    '🇺🇸 美国 | USA',
    '🇺🇸 美国 01',
    '🇺🇸 美国 05',
    '🇺🇸 美国-纽约-001-1A',
    '🇺🇸 美国-V6|01 2',
    '🇺🇸 美国',
    '🇺🇸 美国01',
    '🇺🇸 美国1',
    '🇺🇸 美国10',
    '🇺🇸 美国2',
    '🇺🇸 美国20',
    '🇺🇸 美国3',
    '🇺🇸 美国节点',
    '🇺🇸 美国免费',
    '🇺🇸 美国免费仅ipv6',
    '🇺🇸 美国cf',
    '🇺🇸 美国NO.1-1A',
    '🇺🇸 美国NO.2-1A',
    '🇺🇸 免费-美国1',
    '🇺🇸 Dedi 2T13号',
    '🇺🇸 Dedi CF 30M/s',
    '🇺🇸 LAX v4',
    '🇺🇸 No.539_[US]❌\U0001F9EAsalmoncloud_x0.5_1000M_美国/163/4837/cmi/Netflix/gpt',
    '🇺🇸 RackNerd hy2',
    '🇺🇸 RackNerd vless',
    '🇺🇸 US 优选',
    '🇺🇸 US CF 44MB/s',
    '🇺🇸 US ORACLE',
    '🇺🇸 US_1 | ⬇️ 6.7MB/s',
    '🇺🇸 virtnet CF',
    '🇻🇳 [VN]越南-HoChiMinh',
    '🇻🇳 其他13-VN',
    '🇻🇳 越南 | VNM 10',
    '🇻🇳 越南 | VNM 2',
    '🇻🇳 越南 | VNM',
    '🇻🇳 越南 01',
    '⓪TJ.US空灵 [备用] [公益]|NF*|AI x0.8',
    '❶gR.HK灵魂|NF x1',
    '❶gR.HKT铠甲|NF|D+ x1',
    '❶gR.JP忍者|荐|NF|D+|AI x1',
    '❶gR.JP星移|NF|D+|AI x1',
    '❶gR.RU西亚|联通 x1',
    '❶gR.UK威廉|BBC|NF|D+|AI x1',
    '❶gR.US胜地|HBO|NF*|AI x1',
    '❷gR.HK安魂|荐|阿里云|NF x1',
    '❷gR.HK嘉禾|阿里云|NF x1',
    '❷gR.HK铠甲|TVB|NF|D+ x1',
    '❷gR.JP死神|NF|D+|AI x1',
    '❷gR.JP星移|NF|D+|AI x0.8',
    '❷gR.TW台湾|动画疯|NF|D+|AI x1',
    '❷gR.US川谱|v6|NF*|D+|AI x1',
    '❷gR.US胜地|NF*|AI x1',
    '❷TJ.TW台湾|动画疯|NF|D+|AI x1',
    '❸gR.HK判官|荐|NF|D+ x1',
    '❸gR.HK契约|NF|D+ x1',
    '❸gR.JP大和 x0.8',
    '❸gR.JP和服|v6|NF|D+|AI x0.8',
    '❸gR.JP柯南|NF|D+|AI x1',
    '❸gR.SG星岛|NF|AI x1',
    '❸gR.TW宝岛|荐|NF|D+|AI x1',
    '❸gR.TW台北|荐|NF|D+|AI x1',
    '❸gR.TW彰化|荐|NF|D+|AI x1',
    '❸gR.US川谱|v6|NF*|D+|AI x1',
    '❸gR.US加州|NF*|D+|AI x1',
    '❸H2.HK波澜|NF|D+ x1',
    '❸H2.HK九龙|NF|D+ x1',
    '❻gR.HK波澜|NF|D+ x1',
    '❻gR.HK九龙|NF|D+ x1',
    '❻gR.HK判官|荐|NF|D+ x1',
    '❻gR.HK契约|NF|D+ x1',
    '❻gR.TW剑魂|NF|D+|AI x1',
    '❻gR.TW台北|荐|NF|D+|AI x1',
    '❻gR.TW彰化|NF|D+|AI x1',
    '❻gR.US加州|v6|NF*|D+|AI x1',
    '❻gR.US王者 II|NF*|D+|AI x1',
    '❻gR.US无量 [下载专用]|AI x0',
    '❻TJ.TW剑魂|荐|NF|D+|AI x1',
    '❻V2.TW宝岛|荐|NF|D+|AI x1',
    '❻V2.TW剑魂|NF|D+|AI x1',
    '❻V2.TW彰化|NF|D+|AI x1',
    '阿根廷01标准线路',
    '阿联酋01标准线路',
    '阿塞拜疆01原生线路',
    '爱尔兰01标准线路',
    '爱沙尼亚01原生线路',
    '奥地利01标准线路',
    '澳大利亚01标准线路',
    '澳门 01',
    '巴基斯坦01原生线路',
    '巴林01原生线路',
    '巴西01标准线路',
    '保加利亚01标准线路',
    '比利时01标准线路',
    '波兰01标准线路',
    '丹麦01原生线路',
    '德国 01',
    '德国01标准线路',
    '俄罗斯01标准线路',
    '法国 01',
    '法国01原生线路',
    '防失联 ftqfabu.com',
    '菲律宾01标准线路',
    '芬兰01标准线路',
    '哥伦比亚01标准线路',
    '韩国 01',
    '韩国01标准线路',
    '荷兰 01',
    '荷兰01标准线路',
    '加拿大01标准线路',
    '柬埔寨01标准线路',
    '捷克国01标准线路',
    '拉脱维亚01标准线路',
    '立陶宛01标准线路',
    '罗马尼亚01原生线路',
    '马来西亚01原生线路',
    '马斯喀特01原生线路',
    '美国 01',
    '美国01原生线路',
    '美国02原生线路',
    '美国03原生线路',
    '美国04原生线路',
    '孟加拉国01标准线路',
    '秘鲁01原生线路',
    '墨西哥01标准线路',
    '南非01标准线路',
    '挪威01标准线路',
    '葡萄牙01标准线路',
    '日本01标准线路',
    '日本02标准线路',
    '日本03标准线路',
    '日本04标准线路',
    '瑞典 01',
    '瑞典 02',
    '瑞典01原生线路',
    '瑞士 01',
    '瑞士01标准线路',
    '沙特阿拉伯01标准线路',
    '台湾01原生线路',
    '台湾02原生线路',
    '泰国01原生线路',
    '土耳其01标准线路',
    '乌克兰 01',
    '乌克兰01标准线路',
    '西班牙01标准线路',
    '希腊01标准线路',
    '香港 01',
    '香港 02',
    '香港01解锁线路',
    '香港02解锁线路',
    '新加坡 01',
    '新加坡 02',
    '新加坡 03',
    '新加坡 04',
    '新加坡 05',
    '新加坡01解锁线路',
    '新加坡02解锁线路',
    '以色列01标准线路',
    '意大利01标准线路',
    '印度01标准线路',
    '印度尼西亚01标准线路',
    '英国01标准线路',
    '越南01标准线路',
    '智力01原生线路',
    '中非共和国 01',
    '中非共和国 02',
    'CN1•❷gR.JP死神|NF|D+|AI x1',
    'CN1•❷gR.TW台湾|动画疯|NF|D+|AI x1',
    'CN1•❸gR.HK契约|NF|D+ x1',
    'CN1•❸gR.JP大和 x0.8',
    'CN1•❸gR.JP和服|v6|NF|D+|AI x0.8',
    'CN1•❸gR.JP柯南|NF|D+|AI x1',
    'CN1•❸gR.SG星岛|NF|AI x1',
    'CN1•❸gR.TW宝岛|荐|NF|D+|AI x1',
    'CN1•❸gR.TW台北|荐|NF|D+|AI x1',
    'CN1•❸gR.TW彰化|荐|NF|D+|AI x1',
    'CN1•❸gR.US川谱|v6|NF*|D+|AI x1',
    'CN1•❸H2.HK波澜|NF|D+ x1',
    'CN1•❸H2.HK九龙|NF|D+ x1',
    'CN1•❻gR.HK波澜|NF|D+ x1',
    'CN1•❻gR.HK九龙|NF|D+ x1',
    'CN1•❻gR.HK判官|荐|NF|D+ x1',
    'CN1•❻gR.HK契约|NF|D+ x1',
    'CN1•❻gR.TW剑魂|NF|D+|AI x1',
    'CN1•❻gR.TW台北|荐|NF|D+|AI x1',
    'CN1•❻gR.TW彰化|NF|D+|AI x1',
    'CN1•❻gR.US加州|v6|NF*|D+|AI x1',
    'CN1•❻gR.US王者 II|NF*|D+|AI x1',
    'CN1•❻V2.TW宝岛|荐|NF|D+|AI x1',
    'CN1•❻V2.TW剑魂|NF|D+|AI x1',
    'CN2•❸gR.SG星岛|NF|AI x1',
    'CN2•❸gR.TW宝岛|荐|NF|D+|AI x1',
    'CN2•❸gR.TW彰化|荐|NF|D+|AI x1',
    'CN2•❸H2.HK九龙|NF|D+ x1',
    'CN2•❻gR.HK九龙|NF|D+ x1',
    'CN2•❻gR.TW剑魂|NF|D+|AI x1',
    'CN2•❻gR.TW台北|荐|NF|D+|AI x1',
    'CN2•❻V2.TW剑魂|NF|D+|AI x1',
]


def load_toml(path: str):
    if tomllib is None:
        raise RuntimeError("No TOML loader available (tomllib/tomli/toml required)")
    with open(path, "rb") as f:
        data = f.read()
    # Strip UTF-8 BOM if present
    if data.startswith(b"\xef\xbb\xbf"):
        data = data[3:]
    # tomllib in stdlib accepts text; use loads for consistent behavior
    if hasattr(tomllib, 'loads'):
        return tomllib.loads(data.decode('utf-8'))
    else:
        # fall back to load via BytesIO
        import io
        return tomllib.load(io.BytesIO(data))


def parse_rules(data: dict):
    out = []
    node_pref = data.get("node_pref") or {}
    for rn in node_pref.get("rename_node", []) or []:
        match = rn.get("match")
        replace = rn.get("replace")
        if match is not None and replace is not None:
            out.append((match, replace))
    return out


def prepare_replacement(repl: str) -> str:
    # toml uses $1 $2 style. Python wants \1, but raw strings need \n
    def dollar_to_backref(m):
        return "\\{}".format(m.group(1))

    # Convert $1, $2 to \1, \2
    return re.sub(r"\$(\d+)", dollar_to_backref, repl)


def compile_pattern(pat: str):
    # Use the regex module (if available) for better Unicode support.
    try:
        # Normalize `\x{...}` escapes to `\uXXXX` or `\UXXXXXXXX` so it's
        # accepted inside character classes and by both `re` and `regex`.
        import re as _stdre

        def _hex_to_unicode(m) -> str:
            hx = m.group(1)
            val = int(hx, 16)
            if val <= 0xFFFF:
                return "\\u" + hx.zfill(4).upper()
            else:
                return "\\U" + hx.zfill(8).upper()

        pat = _stdre.sub(r"\\x\{([0-9A-Fa-f]+)\}", _hex_to_unicode, pat)
        # Provide a friendly error when using builtin `re` with unsupported
        # unicode/PCRE extensions such as `\x{...}` or `\p{...}`.
        if getattr(re, '__name__', '') == 're':
            if '\\x{' in pat or '\\p{' in pat:
                raise RuntimeError(
                    "pattern appears to use PCRE/unicode escapes (\\x{...} or \\p{...}), 're' doesn't support these. "
                    "Install the 'regex' package or run with --require-regex."
                )
        # For PCRE-style inline flags like (?i:) we can just compile as-is
        return re.compile(pat, re.UNICODE)
    except Exception as e:
        raise


def apply_rules(name: str, rules: list[tuple[str,str]], first: bool = False):
    result = name
    applied = []
    for i, (m, r) in enumerate(rules, 1):
        try:
            pattern = compile_pattern(m)
        except Exception as e:
            applied.append((i, m, r, False, f"compile error: {e}"))
            continue
        repl = prepare_replacement(r)
        try:
            if first:
                new = pattern.sub(repl, result, count=1)
            else:
                new = pattern.sub(repl, result)
        except Exception as e:
            applied.append((i, m, r, False, f"sub error: {e}"))
            continue
        if new != result:
            applied.append((i, m, r, True, new))
            result = new
    return result, applied


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--toml", default=DEFAULT_TOML, help="Path to TOML config")
    parser.add_argument("--cases", default=None, help="(Optional) path to a Python file with `cases` list or a text file with one case per line")
    parser.add_argument("--json", action="store_true", help="Output result as JSON")
    parser.add_argument("--out", default=DEFAULT_OUT, help="(Optional) path to output file. Extension .json writes JSON, otherwise plain text. Defaults to results.json in script directory.")
    parser.add_argument("--first", action="store_true", help="Only replace first match per rule (simulate count=1)")
    parser.add_argument("--require-regex", action="store_true", help="Require third-party `regex` module; exit with error if not available")
    args = parser.parse_args()

    if not os.path.exists(args.toml):
        print(f"ERROR: TOML file not found: {args.toml}")
        return 2

    # load test cases (either from file or default 'cases')
    if args.cases:
        if args.cases.endswith('.py'):
            ns = {}
            with open(args.cases, 'r', encoding='utf8') as f:
                code = f.read()
            exec(code, ns)
            testcases = ns.get('cases', [])
        else:
            with open(args.cases, 'r', encoding='utf8') as f:
                testcases = [line.strip() for line in f if line.strip()]
    else:
        testcases = cases

    toml_data = load_toml(args.toml)
    rules = parse_rules(toml_data)

    if args.require_regex and getattr(re, '__name__', '') == 're':
        print("Error: builtin 're' is in use and '--require-regex' specified. Please install 'regex'.")
        return 5

    results = []
    for case in testcases:
        transformed, applied = apply_rules(case, rules, first=args.first)
        results.append({
            'original': case,
            'transformed': transformed,
            'applied': [
                {
                    'rule_index': a[0],
                    'match': a[1],
                    'replace': a[2],
                    'ok': a[3],
                    'result': a[4],
                }
                for a in applied
            ],
        })

    # Build output string (JSON or text) for printing or writing
    if args.json:
        output_text = json.dumps(results, ensure_ascii=False, indent=2)
    else:
        props = []
        for r in results:
            props.append('---')
            props.append(f"Original: {r['original']}")
            props.append(f"Final: {r['transformed']}")
            if r['applied']:
                props.append('Applied rules:')
                for a in r['applied']:
                    props.append(f"  {a['rule_index']}: match={a['match']!s} -> repl={a['replace']!s} -> {a['result']}")
            else:
                props.append('No rules applied')
        output_text = '\n'.join(props)

    # If --out specified, write to file, otherwise print to stdout
    if args.out:
        out_path = args.out
        try:
            os.makedirs(os.path.dirname(out_path) or '.', exist_ok=True)
            if args.json or out_path.lower().endswith('.json'):
                with open(out_path, 'w', encoding='utf8') as f:
                    f.write(json.dumps(results, ensure_ascii=False, indent=2))
            else:
                with open(out_path, 'w', encoding='utf8') as f:
                    f.write(output_text)
            print(f"Wrote results to {out_path}")
        except Exception as e:
            print(f"ERROR: Failed to write to {out_path}: {e}")
            return 3
    else:
        print(output_text)

    # Quick assertions: ensure specific multiplier cases transform as expected
    try:
        expected_map = {
            '🇩🇪 德国-V6|01 0.5x': '🇩🇪 德国-V6|01 [x0.5]',
            '🇭🇰 香港-V6|05 0.5x': '🇭🇰 香港-V6|05 [x0.5]',
            '🇳🇱 荷兰-V6|01 0.5x': '🇳🇱 荷兰-V6|01 [x0.5]',
            '🇭🇰 [CN]HK专线01-【5倍率】': '🇭🇰 [CN]HK专线01-[x5]',
            '🇸🇬 [CN]SG专线01-【5倍率】': '🇸🇬 [CN]SG专线01-[x5]',
            '🇹🇼 [CN]TW专线01-【5倍率】': '🇹🇼 [CN]TW专线01-[x5]',
        }
        res_map = {r['original']: r['transformed'] for r in results}
        for k, v in expected_map.items():
            if k not in res_map:
                print(f"WARNING: test case not present: {k}")
            elif res_map[k] != v:
                print(f"ERROR: expected {k} -> {v}, got {res_map[k]}")
                raise SystemExit(4)
    except Exception:
        pass

    return 0


if __name__ == '__main__':
    raise SystemExit(main())

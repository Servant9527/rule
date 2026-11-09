#!/bin/sh /etc/rc.common
# upay-timesync: 开机时从 upay.10010.com 的 HTTP Date 头同步时间
# 适用场景: 路由器只有停机卡(免流卡)时, NTP (UDP 123) 不通, 但 upay.10010.com 是免流域名可直达
# 正常流量卡时 NTP 本来就能用, 本脚本不干扰 NTP, 只是多一个对时渠道
# 安装: 放到 /etc/init.d/upay-timesync, chmod +x, /etc/init.d/upay-timesync enable
# 另见 hotplug 脚本 /etc/hotplug.d/iface/99-ntp-sync (WAN 上线时强制 NTP, 已装)
# 注意: 本脚本是 oneshot, 不用 procd, 避免 procd 反复拉起造成每 5 秒跑一次

START=99
STOP=10

start() {
    /etc/upay-timesync.sh &
}

stop() {
    :
}

#!/bin/sh /etc/rc.common
# upay-timesync: 开机时从 upay.10010.com 的 HTTP Date 头同步时间
# 适用场景: 路由器只有停机卡(免流卡)时, NTP (UDP 123) 不通, 但 upay.10010.com 是免流域名可直达
# 正常流量卡时 NTP 本来就能用, 本脚本不干扰 NTP, 只是多一个对时渠道
# 安装: 放到 /etc/init.d/upay-timesync, chmod +x, /etc/init.d/upay-timesync enable
# 另见 hotplug 脚本 /etc/hotplug.d/iface/99-ntp-sync (WAN 上线时强制 NTP, 已装)

START=99
STOP=10
USE_PROCD=1

start_service() {
    procd_open_instance
    procd_set_param command /bin/sh /etc/upay-timesync.sh
    procd_set_param respawn 0
    procd_close_instance
}

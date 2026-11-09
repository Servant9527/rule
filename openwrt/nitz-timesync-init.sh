#!/bin/sh /etc/rc.common
# nitz-timesync: 开机时从 USB modem 的基站时间 (NITZ) 同步系统时间
# 跟 F50 一个路子, 不依赖上网/DNS/节点; 只跑一次的 oneshot, 不用 procd
# 安装: 放到 /etc/init.d/nitz-timesync, chmod +x, /etc/init.d/nitz-timesync enable

START=99
STOP=10

start() {
    /etc/nitz-timesync.sh &
}

stop() {
    :
}

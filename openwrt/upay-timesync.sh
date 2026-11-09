#!/bin/sh
# /etc/upay-timesync.sh - 从 upay.10010.com 的 HTTP Date 头对时, 再补一次 NTP
# 被 /etc/init.d/upay-timesync (START=99) 在开机时调用; 也可手动执行
# 日志写到系统日志, 可用 logread -e upay-timesync 查看

# 等网络就绪 (最多等 60 秒)
for _ in $(seq 1 12); do
    ip route get 1.1.1.1 >/dev/null 2>&1 && break
    sleep 5
done

# 1) 先试 NTP (有正常网时直接走 NTP, 最准)
if /usr/sbin/ntpd -q -p ntp.aliyun.com -p 0.openwrt.pool.ntp.org >/dev/null 2>&1; then
    logger -t upay-timesync "NTP sync ok: $(date)"
    exit 0
fi

# 2) NTP 不通(只有停机卡时), 改从 upay.10010.com 的 Date 头对时
DATE_HDR=""
for _ in 1 2 3; do
    DATE_HDR=$(curl -skI -m 10 https://upay.10010.com 2>/dev/null | grep -i '^date:' | sed 's/^[Dd]ate: *//;s/\r$//')
    [ -n "$DATE_HDR" ] && break
    sleep 3
done

if [ -n "$DATE_HDR" ]; then
    # Date 头是 GMT, 用 -u 按 UTC 设置, 本地时间由时区换算
    if date -u -s "$DATE_HDR" >/dev/null 2>&1; then
        logger -t upay-timesync "HTTP Date sync ok from upay.10010.com: $DATE_HDR -> $(date)"
    else
        logger -t upay-timesync "date -s failed for: $DATE_HDR"
    fi
else
    logger -t upay-timesync "failed: no Date header from upay.10010.com"
fi
exit 0

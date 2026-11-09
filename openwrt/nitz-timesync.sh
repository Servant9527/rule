#!/bin/sh
# /etc/nitz-timesync.sh - 从 USB modem 的基站时间 (NITZ, AT+CCLK?) 对时
# 适用场景: 路由器只有停机卡时, NTP 不通、DNS 不通, 但 modem 连上基站后自带时间
# 原理: 跟中兴 F50 一样, 直接问 modem 要时间, 不依赖上网、DNS、节点
# 被 /etc/init.d/nitz-timesync (START=99) 在开机时调用; 也可手动执行
# 日志: logread -e nitz-timesync

# 找所有可能的 AT 口
for DEV in /dev/ttyUSB* /dev/ttyACM* /dev/cdc-wdm*; do
    [ -e "$DEV" ] || continue
    # 发 AT+CCLK? 读 modem 时间, 超时 3 秒
    RESP=$(timeout 3 sh -c "exec 3<>$DEV; echo -e 'AT+CCLK?\r' >&3; head -c 256 <&3" 2>/dev/null)
    # 找 +CCLK: "yy/MM/dd,hh:mm:ss+zz" 这一行
    CCLK=$(echo "$RESP" | grep -o '+CCLK: *"[^"]*"' | head -1)
    [ -n "$CCLK" ] || continue
    # 提取 "26/11/09,16:30:00+32" 这种, 取前 17 个字符 yy/MM/dd,hh:mm:ss
    TSTR=$(echo "$CCLK" | sed 's/+CCLK: *"//;s/"//;s/\(..\/..\/..,...:..:..\).*/\1/')
    # 转成 date 能认的格式: 20yy-MM-dd hh:mm:ss (按本地时区, modem 给的是本地时间)
    YY=$(echo "$TSTR" | cut -c1-2)
    MO=$(echo "$TSTR" | cut -c4-5)
    DD=$(echo "$TSTR" | cut -c7-8)
    HM=$(echo "$TSTR" | cut -c10-17)
    if date -s "20$YY-$MO-$DD $HM" >/dev/null 2>&1; then
        logger -t nitz-timesync "NITZ sync ok from $DEV: $TSTR -> $(date)"
        exit 0
    else
        logger -t nitz-timesync "date -s failed for $DEV: $TSTR"
    fi
done
logger -t nitz-timesync "failed: no NITZ time from any modem"
exit 0

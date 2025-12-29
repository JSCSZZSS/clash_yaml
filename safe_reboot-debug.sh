cat << 'EOF' > /usr/bin/safe_reboot.sh
#!/bin/sh
# 使用后台执行和 wait 机制，避免依赖不稳定的 timeout 工具

PING_COUNT=4
PING_WAIT=2 
TARGET_IP="8.8.8.8"

# 1. 在后台执行 ping，避免卡死
ping -c $PING_COUNT -W $PING_WAIT $TARGET_IP > /dev/null 2>&1 &
PING_PID=$! # 捕获 ping 进程的 PID

# 2. 等待 ping 进程结束，并捕获其退出码
# wait 命令会等待指定的 PID 结束，并返回该进程的退出码
wait $PING_PID
PING_EXIT_CODE=$?

# 3. 检查退出码：只有当 ping 100% 丢包时（退出码 1）才执行重启
if [ $PING_EXIT_CODE -eq 1 ]; then
    logger "CRITICAL: WAN Link 100% Loss detected (Code: $PING_EXIT_CODE). Auto-rebooting."
    /sbin/reboot
else
    # 网络正常 (Code 0) 或发生其他非 1 的错误 (如 125/124)，不重启，避免误触
    logger "DEBUG: Network check passed (Code $PING_EXIT_CODE). No action required."
fi
EOF
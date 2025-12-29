cat << 'EOF' > /usr/bin/safe_reboot.sh
#!/bin/sh

PING_COUNT=4
PING_WAIT=2 
TARGET_IP="8.8.8.8"

ping -c $PING_COUNT -W $PING_WAIT $TARGET_IP > /dev/null 2>&1 &
PING_PID=$!

wait $PING_PID
PING_EXIT_CODE=$?

if [ $PING_EXIT_CODE -eq 1 ]; then
    /sbin/reboot
fi
EOF
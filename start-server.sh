#!/bin/bash

# Generate SSH host keys
echo "Generating SSH host keys..."
ssh-keygen -A

# Write authorized_keys from plugin settings
echo "Populating authorized_keys..."
echo "$PLUGIN_AUTHORIZED_KEYS" > /root/.ssh/authorized_keys

# Start sshd
echo "Starting SSH server..."
/usr/sbin/sshd -De "$@" &

# Generate alias and show ssh command
HOST_ALIAS="ci-debug-$DRONE_REPO_NAMESPACE-$DRONE_REPO_NAME-$DRONE_COMMIT"
echo
echo "Open a debug session with the following command:"
echo '    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -J serveo.net root@'$HOST_ALIAS
echo

# Forward with serveo.net
# Connect in a loop to allow debugging at the end of long builds, as Serveo
# normally terminates idle connections after 10 minutes
# Limit connection retries to 10 to prevent abusive behavior and error spam
# when Serveo is down
echo "Connecting to Serveo for forwarding..."
for conn in $(seq 1 10); do
    ssh -R $HOST_ALIAS:22:localhost:22 serveo.net
done

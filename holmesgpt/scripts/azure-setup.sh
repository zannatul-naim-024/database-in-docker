#!/bin/bash

# Setup Azure CLI configuration in writable directory
if [ -d "/root/.azure" ]; then
    mkdir -p /tmp/azure
    cp -r /root/.azure/* /tmp/azure/ 2>/dev/null || true
    echo "Azure credentials copied to writable directory"
fi

# Execute the original command
exec "$@"

#!/bin/sh
set -e

cd /data

if [ -f .runner ]; then
    echo "Runner already registered, starting..."
else
    echo "Registering runner with ${FORGEJO_URL}..."
    until forgejo-runner create-runner-file --connect \
        --instance "${FORGEJO_URL}" \
        --name "${RUNNER_NAME:-docker-runner}" \
        --secret "${FORGEJO_RUNNER_SECRET}"; do
        echo "Forgejo not ready yet, waiting 10s..."
        sleep 10
    done
    echo "Runner registered successfully!"
fi

exec forgejo-runner daemon --config /config.yaml

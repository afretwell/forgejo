#!/bin/sh
# Starts Forgejo, then (once it's up) creates the admin user and registers
# the runner secret. Both steps are safe to repeat on every start.

(
    until wget -q -O /dev/null "http://localhost:${FORGEJO__server__HTTP_PORT}/api/healthz" 2>/dev/null; do
        sleep 3
    done

    su git -c "forgejo admin user create --admin \
        --username '${FORGEJO_ADMIN_USER}' \
        --password '${FORGEJO_ADMIN_PASSWORD}' \
        --email '${FORGEJO_ADMIN_EMAIL}' \
        --must-change-password=false" >/dev/null 2>&1 \
        && echo "Admin user '${FORGEJO_ADMIN_USER}' created." \
        || echo "Admin user '${FORGEJO_ADMIN_USER}' already exists."

    su git -c "forgejo forgejo-cli actions register \
        --name docker-runner \
        --secret '${FORGEJO_RUNNER_SECRET}'" \
        && echo "Runner secret registered."
) &

exec /usr/bin/entrypoint /usr/bin/s6-svscan /etc/s6

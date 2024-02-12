#!/bin/sh
# https://stackoverflow.com/a/38732187/1935918
#set -e

if [ -f /usr/src/app/tmp/pids/delayed_job.pid ]; then
  rm /usr/src/app/tmp/pids/delayed_job.pid
fi

# Then exec the container's main process (what's set as CMD in the docker-compose.yml).
exec bundle exec "$@"

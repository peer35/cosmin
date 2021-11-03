#!/bin/sh
# https://stackoverflow.com/a/38732187/1935918
set -e

if [ -f /usr/src/app/tmp/pids/server.pid ]; then
  rm /usr/src/app/tmp/pids/server.pid
fi

bundle exec rake db:migrate
rails generate delayed_job

exec bundle exec "$@"

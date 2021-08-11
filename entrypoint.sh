#!/bin/bash
rm -f /var/app/tmp/pids/server.pid
bundle check > /dev/null 2>&1 || bundle install -j4
echo "> Executing 'yarn install' on web"
yarn install

if [ "$#" == 0 ]
then
    bundle exec rake db:create db:migrate
    exec bundle exec rails server -b '0.0.0.0'
fi
exec $@
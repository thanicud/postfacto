#!/bin/bash

set -e

# pushd api
#   bundle exec rake db:create db:migrate
#   bundle exec rake
# popd
#
# pushd web
#   gulp spec-app
# popd
#
# ./integrate

pushd web
  gulp mock-google-auth-server &
  MOCK_PID=$!
  trap 'kill -9 $MOCK_PID' EXIT
  sleep 20
popd

pushd api
  bundle exec rake db:create db:migrate db:test:prepare
  RAILS_ENV=test bundle exec rake db:seed
  GOOGLE_AUTH_ENDPOINT=http://localhost:3100/auth bundle exec rails server -e test &
  RAILS_PID=$!
  trap 'kill -9 $RAILS_PID' EXIT
  sleep 10
popd

pushd e2e
  bundle exec rspec spec
popd

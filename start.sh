# This file is how Fly starts the server (configured in fly.toml). Before starting
# the server though, we need to run any migrations that haven't yet been
# run, which is why this file exists in the first place.
# Learn more: https://community.fly.io/t/sqlite-not-getting-setup-properly/4386

#!/bin/sh

set -ex
mkdir -p /data/database
mkdir -p /data/uploads
chmod -Rf 777 /data/database
chmod -Rf 777 /data/uploads


npx directus bootstrap
npx directus start

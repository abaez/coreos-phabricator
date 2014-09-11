#!/bin/bash

set -e
set -x

pushd /srv/phabricator

if [ -e /config/script.pre ]; then
    echo "Applying pre-configuration script..."
    /config/script.pre
else
    echo "+++++ MISSING CONFIGURATION +++++"
    echo ""
    echo "You must specify a preconfiguration script for "
    echo "this Docker image.  To do so: "
    echo ""
    echo "  1) Create a 'script.pre' file in a directory "
    echo "     called 'config', somewhere on the host. "
    echo ""
    echo "  2) Run this Docker instance again with "
    echo "     -v path/to/config:/config passed as an "
    echo "     argument."
    echo ""
    echo "+++++ BOOT FAILED! +++++"
    exit 1
fi

popd

echo "Upgrading Phabricator..."

pushd /srv/libphutil
git pull --rebase
popd

pushd /srv/arcanist
git pull --rebase
popd

pushd /srv/phabricator
git pull --rebase
popd

if [ -e /config/script.premig ]; then
    echo "Applying pre-migration script..."
    /config/script.premig
fi

echo "Applying any pending DB schema upgrades..."
/srv/phabricator/bin/storage upgrade --force

pushd /srv/phabricator

if [ -e /config/script.post ]; then
    echo "Applying post-configuration script..."
    /config/script.post
fi

popd

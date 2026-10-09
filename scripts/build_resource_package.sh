#!/bin/bash

# If not stated otherwise in this file or this component's LICENSE file the
# following copyright and licenses apply:
#
# Copyright 2025 RDK Management
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
set -e
if [ $# -ne 1 ] || [ "$1" != "brcm-ref" ]; then
    echo "Usage: $0 brcm-ref"
    exit 1
fi

SCRIPTS_DIR=$(readlink -m "$(dirname "${BASH_SOURCE[0]}")")
META_ROOT="$(dirname "$SCRIPTS_DIR")"
CERTS_DIR="${META_ROOT}/deps/bolt-engineering-certificates"
PACKAGE_DIR="$HOME/bolts"

# Create directories to store BBC iPlayer and BBC Sounds related files
RESOURCE_PACKAGE_DIR="${META_ROOT}/deps/com.rdkcentral.bbc.resource.$1"
echo "Resource package directory: $RESOURCE_PACKAGE_DIR"
mkdir -p $RESOURCE_PACKAGE_DIR $RESOURCE_PACKAGE_DIR/usr/share/certificates
mkdir -p $RESOURCE_PACKAGE_DIR $RESOURCE_PACKAGE_DIR/usr/share/oipf

rm -rf "$RESOURCE_PACKAGE_DIR/usr/share/certificates"
cp -r "$META_ROOT/deps/certificates" "$RESOURCE_PACKAGE_DIR/usr/share/"
echo "Copied certificates"

cp $META_ROOT/deps/oipf-bbc/dist/stb/oipf-bbc.js $META_ROOT/deps/oipf-bbc/dist/stb/oipf-bbc.css $RESOURCE_PACKAGE_DIR/usr/share/oipf/
echo "Copied oipf related dependencies"

APP_ID="com.rdkcentral.bbc.resource.$1"
TARBALL="${RESOURCE_PACKAGE_DIR}/${APP_ID}.tgz"
APPLICATION_MANIFEST="${META_ROOT}/package-configs/${APP_ID}.json"

echo "Tarball: $TARBALL"
echo "Application manifest: $APPLICATION_MANIFEST"
tar -czf "$TARBALL" -C $RESOURCE_PACKAGE_DIR usr

cd $RESOURCE_PACKAGE_DIR
bolt pack $APPLICATION_MANIFEST $TARBALL
BOLT_FILE=$(ls *.bolt 2>/dev/null | grep -v '_signed' | head -1)
if [ -z "$BOLT_FILE" ]; then
    echo "ERROR: No .bolt file found in $RESOURCE_PACKAGE_DIR after bolt pack."
    echo "       Directory listing:"
    ls -la "$RESOURCE_PACKAGE_DIR"
    exit 1
fi
echo "          Generated package: $BOLT_FILE"

echo "Signing with ralfpack..."
ralfpack sign \
    --pkcs12="$CERTS_DIR/certs/com.rdkcentral.ralf.p12" \
    --passphrase="RDKMRalf" \
    "$BOLT_FILE"
echo "          Signed: $BOLT_FILE"


# Copy the package to package directory
cp $BOLT_FILE $PACKAGE_DIR
echo "Copied the $BOLT_FILE to Package directory: $PACKAGE_DIR"

echo "Bolt package generated"
echo "==================================================================="
ls -lh *.bolt 2>/dev/null | sed 's/^/    /' || echo "    (no .bolt files found)"
echo "==================================================================="
cd $META_ROOT

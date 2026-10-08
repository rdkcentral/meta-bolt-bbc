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
#!/bin/bash
if [ $# -ne 1 ]; then
    echo "Usage: $0 <platform>"
    echo "<platform> shall be brcm-ref/rpi4 based on the platform"
    exit 1
fi
SCRIPTS_DIR=$(readlink -m "$(dirname "${BASH_SOURCE[0]}")")
META_ROOT="$(dirname "$SCRIPTS_DIR")"
CERTS_DIR="${META_ROOT}/deps/bolt-engineering-certificates"

# Create directories to store BBC iPlayer and BBC Sounds related files
RESOURCE_PACKAGE="${META_ROOT}/deps/com.rdkcentral.bbc.resource.$1"
echo "Resource package directory: $RESOURCE_PACKAGE"
mkdir -p $RESOURCE_PACKAGE $RESOURCE_PACKAGE/usr/share/certificates
mkdir -p $RESOURCE_PACKAGE $RESOURCE_PACKAGE/usr/share/oipf

if [ -z "$(find "$RESOURCE_PACKAGE/usr/share/certificates" -maxdepth 1 -type f -print -quit)" ]; then
    cp -r $META_ROOT/deps/certificates $RESOURCE_PACKAGE/usr/share/
    echo "Copied certificates"
fi
cp $META_ROOT/deps/oipf-bbc/dist/stb/oipf-bbc.js $META_ROOT/deps/oipf-bbc/dist/stb/oipf-bbc.css $RESOURCE_PACKAGE/usr/share/oipf/
echo "Copied oipf related dependencies"

APP_ID="com.rdkcentral.bbc.resource.$1"
TARBALL="${RESOURCE_PACKAGE}/${APP_ID}.tgz"
APPLICATION_MANIFEST="${META_ROOT}/package-configs/${APP_ID}.json"

echo "Tarball: $TARBALL"
echo "Application manifest: $APPLICATION_MANIFEST"
tar -czf "$TARBALL" -C $RESOURCE_PACKAGE usr

cd $RESOURCE_PACKAGE
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

echo "Bolt package generated"
echo "==================================================================="
ls -lh *.bolt 2>/dev/null | sed 's/^/    /' || echo "    (no .bolt files found)"
echo "==================================================================="
cd $META_ROOT

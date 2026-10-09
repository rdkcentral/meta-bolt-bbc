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
    echo "Usage: $0 <APP_ID>"
    echo "APP_ID shall be bbc-sounds or bbc-iplayer"
    exit 1
fi

if [[ "$1" != "bbc-sounds" ]] && [[ "$1" != "bbc-iplayer" ]]; then
    echo "Usage: $0 <APP_ID>"
    echo "APP_ID shall be bbc-sounds or bbc-iplayer"
    exit 1 
fi

SCRIPTS_DIR=$(readlink -m "$(dirname "${BASH_SOURCE[0]}")")
META_ROOT="$(dirname "$SCRIPTS_DIR")"
CERTS_DIR="${META_ROOT}/deps/bolt-engineering-certificates"

# Create directories to store BBC iPlayer and BBC Sounds related files
APP_DIR="${META_ROOT}/deps/com.rdkcentral.$1"
mkdir $APP_DIR
echo "Application directory : $APP_DIR created."

APP_ID="com.rdkcentral.$1"
APPLICATION_MANIFEST="${META_ROOT}/package-configs/${APP_ID}.bolt.json"

echo "Application manifest: $APPLICATION_MANIFEST"

cd $APP_DIR
bolt make $1 --force-install --key=$CERTS_DIR/certs/com.rdkcentral.ralf-private.key --cert=$CERTS_DIR/certs/com.rdkcentral.ralf-public.crt
BOLT_FILE=$(ls *.bolt 2>/dev/null | grep -v '_signed' | head -1)
if [ -z "$BOLT_FILE" ]; then
    echo "ERROR: No .bolt file found in $APP_DIR after bolt pack."
    echo "       Directory listing:"
    ls -la "$APP_DIR"
    exit 1
fi
echo "          Generated package: $BOLT_FILE"

echo "Bolt package generated"
echo "==================================================================="
ls -lh *.bolt 2>/dev/null | sed 's/^/    /' || echo "    (no .bolt files found)"
echo "==================================================================="
cd $META_ROOT

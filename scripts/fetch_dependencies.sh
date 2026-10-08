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

SCRIPTS_DIR=$(readlink -m "$(dirname "${BASH_SOURCE[0]}")")
META_ROOT="$(dirname "$SCRIPTS_DIR")"
${META_ROOT}/repo-sync
OIPF_WORKSPACE=${META_ROOT}/deps/oipf-bbc

if ! command -v node &>/dev/null; then
    echo "Error: Node.js is not installed or not in PATH."
    echo "  Install it from https://nodejs.org or via a version manager (nvm, fnm)."
    exit 1
fi

if ! command -v npm &>/dev/null; then
    echo "Error: npm is not installed or not in PATH."
    echo "  npm is bundled with Node.js — reinstalling Node should fix this."
    exit 1
fi

if [ ! -d "$OIPF_WORKSPACE" ]; then
    echo "$OIPF_WORKSPACE directory does not exist"
    echo "OIPF JS libraries not fetched, exiting the scripts"
    exit 1
fi

# Build OIPF Library
echo "Building OIPF library (npm run build)"
cd "$OIPF_WORKSPACE"
npm install
npm run build
echo "Build completed"
echo "oipf-bbc.js oipf-bbc.css are present in $OIPF_WORKSPACE/dist/stb"
echo ""


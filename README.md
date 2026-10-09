# meta-bolt-bbc

Bitbake meta layer to build BBC iPlayer and BBC Sounds application.

# Setup and building

See [Setup and building](https://github.com/rdkcentral/meta-bolt-distro/blob/develop/README.md#setup-and-building)
section in the [meta-bolt-distro](https://github.com/rdkcentral/meta-bolt-distro) documentation.

See [Setup and building](https://github.com/rdkcentral/meta-bolt-wpe/blob/develop/README.md#setup-and-building)
section in the [meta-bolt-wpe](https://github.com/rdkcentral/meta-bolt-wpe) documentation.

See [Setup and building](https://github.com/rdkcentral/ralfpack/blob/main/README.md#building-from-source)
section in the [ralfpack](https://github.com/rdkcentral/ralfpack) documentation.

See [Setup](https://github.com/rdkcentral/bolt-tools/blob/main/README.md)
section in the [bolt](https://github.com/rdkcentral/bolt-tools) documentation.

## BBC application building instructions

* Download this repository and enter its root directory.
```
git clone https://github.com/rdkcentral/meta-bolt-bbc.git
cd meta-bolt-bbc
```

## Building WPE BBC runtime as bolt package
Copy package-configs/com.rdkcentral.wpe-bbc.json, package-configs/wpe-bbc.bolt.json to meta-bolt-wpe/package-configs and create WPE BBC runtime using below command
```
bolt make wpe-bbc --install
```

## Building BBC application as bolt package
To create Bolt packages for BBC, ensure that the base package is available in the package store. Refer to the [building the base bolt package](https://github.com/rdkcentral/meta-bolt-distro?tab=readme-ov-file#building-the-base-bolt-package) section to generate the base package and set up the package store.

Ensure that bolt and ralfpack tool is available in the $PATH environment variable using export command as below
```
export PATH=$PATH:$HOME/bolt-tools/bolt/bin:$HOME/ralfpack/target/release
```

Fetch dependencies to build the bolt package
```
./scripts/fetch_dependencies.sh
```

Copy the BBC certificates(private and public key) to deps/certificates directory

Update the appropriate `<userAgent>` and certificate placeholders (`<bbc-iplayer-cert.pem>`, `<bbc-iplayer-key.pem>`, `<bbc-isounds-cert.pem>` and `<bbc-isounds-key.pem>`) in `package-configs/com.rdkcentral.bbc-iplayer.json` and `package-configs/com.rdkcentral.bbc-sounds.json`.

Build the resource package (which contains certificates and oipf related js runtime files)
```
./scripts/build_resource_package.sh brcm-ref
```

Build the bolt package
```
./scripts/build_bolt_package.sh <BBC_APP_NAME>
```
<BBC_APP_NAME> shall be bbc-iplayer or bbc-sounds

## Running BBC bolt packages on device

To run bolt packages on device, use `bolt push` and `bolt run` as explained in [bolt tool usage](https://github.com/rdkcentral/bolt-tools/tree/main/bolt#usage)

```
bolt push <remote> com.rdkcentral.base+0.4.0.bolt
bolt push <remote> com.rdkcentral.bbc.resource.brcm-ref+0.4.0.bolt
bolt push <remote> com.rdkcentral.wpe-bbc+0.5.0.bolt
bolt push <remote> com.rdkcentral.bbc-iplayer+0.5.0.bolt

bolt run <remote> com.rdkcentral.bbc-iplayer+0.5.0.bolt
```

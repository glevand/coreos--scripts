#!/bin/bash -ex

export JENKINS_BUILD=1

enter() {
        bin/cork enter --experimental -- "$@"
}

source .repo/manifests/version.txt
export COREOS_BUILD_ID

# Set up GPG for signing uploads.
gpg --debug-level guru --debug-all --verbose --import "${GPG_SECRET_KEY_FILE}"

# Wipe all of catalyst.
sudo find src/build -maxdepth 3 -type d || true
sudo rm -rf src/build

S=/mnt/host/source/src/scripts
enter ${S}/update_chroot
enter sudo emerge -uv --jobs=2 catalyst
enter sudo ${S}/bootstrap_sdk \
    --sign="${SIGNING_USER}" \
    --sign_digests="${SIGNING_USER}" \
    --upload_root="${UPLOAD_ROOT}" \
    --upload

# Free some disk space only on success to allow debugging failures.
sudo find src/build/catalyst/builds -maxdepth 2 -type d || true
sudo rm -rf src/build/catalyst/builds

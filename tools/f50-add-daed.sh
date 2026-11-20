#!/bin/sh
# Integrate an OpenWrt ARM64 build of the pinned DaedNext distribution.
set -eu
[ "$#" = 1 ] || { echo "Usage: $0 ROOTFS" >&2; exit 2; }
root=$(cd "$1" && pwd)
top=$(cd "$(dirname "$0")/.." && pwd)
[ "$root" != / ] && [ -x "$root/usr/bin/apk" ]
scratch=$(mktemp -d "$root/tmp/f50-daed.XXXXXX")
trap 'rm -rf "$scratch"' EXIT
inside=/tmp/${scratch##*/}
url=https://github.com/Quan-0505/rust-daed/releases/download/v3.2.2/rust-daed-r2s.apk
curl -fsSL --retry 3 "$url" -o "$scratch/daed.apk"
(cd "$scratch"; printf '%s  daed.apk\n' 2f78a7ae8fa97769ded245ff8aa951bd9af8bcb9b554e64ec2cbb54f3294c563 | sha256sum -c -)
# This release uses an independent APK signing key. Extract into scratch only
# after matching the pinned digest; do not add its key or alter APK trust.
mkdir "$scratch/payload"
chroot "$root" /usr/bin/apk extract --allow-untrusted --destination "$inside/payload" "$inside/daed.apk"
payload="$scratch/payload"
test -s "$payload/usr/share/daed/web/index.html"
test -s "$payload/usr/share/daed/geoip.dat"
test -s "$payload/usr/share/daed/geosite.dat"
test -z "$(find "$payload/usr/share/daed" ! -type d ! -type f -print -quit)"
install -m 755 "$payload/usr/bin/daed" "$root/usr/bin/daed"
mkdir -p "$root/usr/share/daed"
cp -a "$payload/usr/share/daed/." "$root/usr/share/daed/"
install -m 644 "$top/openwrt/f50-daed.LICENSE" "$root/usr/share/daed/LICENSE"
printf '%s\n' 'DaedNext v3.2.2: corresponding source, patches and build scripts:' 'https://github.com/Quan-0505/rust-daed/tree/v3.2.2' >"$root/usr/share/daed/SOURCE.txt"
install -m 755 "$top/openwrt/f50-daed.init" "$root/etc/init.d/daed"
test ! -e "$root/etc/daed"
test ! -e "$root/etc/rc.d/S95daed"
chroot "$root" /usr/bin/daed --version | grep -F 'version=v3.2.2'

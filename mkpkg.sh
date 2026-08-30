#!/bin/sh
#
# assemble an Octave package tarball from this repository
#
# usage:
#     ./mkpkg.sh            # creates easyh5-<version>.tar.gz in the current dir
#
# the repository keeps every unit at the top level so that it can be used with a
# plain addpath(); Octave's pkg install, on the other hand, ignores any .m file
# that is not under inst/, and silently installs an empty package if inst/ is
# missing, so the tarball has to be built with that layout

set -e

here=$(cd "$(dirname "$0")" && pwd)
version=$(sed -n 's/^Version: *//p' "$here/DESCRIPTION")
pkgname=easyh5-$version
builddir=$(mktemp -d)
target="$builddir/$pkgname"

mkdir -p "$target/inst"

# only ship files that are tracked, so local scratch copies are never packaged
(cd "$here" && git ls-files '*.m' | grep -v '/') | while read -r unit; do
    cp "$here/$unit" "$target/inst/$unit"
done

cp "$here/DESCRIPTION" "$target/DESCRIPTION"
cp "$here/INDEX" "$target/INDEX"
cp "$here/LICENSE_GPLv3.txt" "$target/COPYING"

# every INDEX entry must have a matching unit, otherwise pkg install errors out
awk '/^ /{gsub(/^ +| +$/, "", $0); print}' "$here/INDEX" | while read -r fun; do
    if [ ! -f "$target/inst/$fun.m" ]; then
        echo "error: INDEX lists $fun but inst/$fun.m is missing" >&2
        exit 1
    fi
done

tar -C "$builddir" -czf "$here/$pkgname.tar.gz" "$pkgname"
rm -rf "$builddir"

echo "created $here/$pkgname.tar.gz"
echo "install it with:  pkg install $pkgname.tar.gz"

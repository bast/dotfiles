#!/usr/bin/env bash

# TODO: Look at nixpkgs/pkgs/build-support/setup-hooks/auto-patchelf.sh

set -eu

TOOLS="patchelf xsel"
DEPS="utillinux.out openssl.out icu zlib curl.out lttng-ust libsecret libkrb5"
OUTS="gcc.cc.lib libunwind binutils.bintools_bin $DEPS"

EXE_FILE_STR="$(file $(readlink $(which file)) | cut -d ':' -f 2 | cut -d ',' -f 1)"

function find-extensions {
    find ~/.vscode/extensions/ -maxdepth 2 -type d -ipath '*/ms-dotnettools.csharp-*/.omnisharp'
}

function install-prereqs {
    for DEP in $TOOLS $DEPS; do
        echo nix-env -iA "nixos.$DEP"
    done
}

function get-exes {
    find $EXT_DIR -type f -exec file '{}' \; | grep "$EXE_FILE_STR" | cut -d ":" -f 1
}

function ldd-all {
    get-exes | xargs -n 1 ldd
    find $EXT_DIR -iname '*.so' -exec ldd '{}' 2>&1 \;
}

function resolve { local PACKAGE="$1";
    nix-build -E "with (import <nixpkgs> {}); $PACKAGE" --no-out-link
}

function get-rpath {
    (
        for OUT in $OUTS; do
            echo "$(resolve $OUT)/lib"
        done
        echo -n $EXT_DIR
    ) | tr "\n" ':'
}

function show-missing {
   if ! ldd-all | grep '=> not found'; then
       echo "All libraries resolved"
   fi
}

function patch {
    # echo "Installing prerequisites..."
    # install-prereqs

    echo "Missing before:"
    for EXT_DIR in $(find-extensions); do
        show-missing
    done

    for EXT_DIR in $(find-extensions); do
        echo "Patching extension: ${EXT_DIR}..."

        local RPATH="$(get-rpath)"
        echo "Calulated rpath: $RPATH"

        echo "Patching exes..."
        get-exes
        get-exes | xargs -n 1 chmod u+x
        get-exes | xargs -n 1 patchelf --set-rpath "\$ORIGIN/netcoredeps:$RPATH"
        get-exes | xargs -n 1 patchelf --set-interpreter "$(resolve glibc)/lib/ld-linux-x86-64.so.2"

        echo "Patching libs..."
        find $EXT_DIR -iname '*.so' -ls -exec chmod u+x '{}' \; -exec patchelf --set-rpath $RPATH '{}' \;
    done

    echo "Missing after:"
    for EXT_DIR in $(find-extensions); do
        show-missing
    done
}

if [[ $# -eq 0 ]]; then
    patch
else
    "$@"
fi

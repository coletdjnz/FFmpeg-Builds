#!/bin/bash

LIBX11_REPO="https://gitlab.freedesktop.org/xorg/lib/libx11.git"
LIBX11_COMMIT="934417b1e89fe715b9cf6c0d62a3867fa1f5bccb"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBX11_REPO" "$LIBX11_COMMIT" libx11
    cd libx11

    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --enable-shared
        --disable-static
        --with-pic
        --without-xmlto
        --without-fop
        --without-xsltproc
        --without-lint
        --disable-specs
        --enable-ipv6
    )

    if [[ $TARGET == linux* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    export CFLAGS="$RAW_CFLAGS"
    export LDFLAFS="$RAW_LDFLAGS"

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install

    echo "Libs: -ldl" >> "$FFBUILD_PREFIX"/lib/pkgconfig/x11.pc

    gen-implib "$FFBUILD_PREFIX"/lib/{libX11-xcb.so.1,libX11-xcb.a}
    gen-implib "$FFBUILD_PREFIX"/lib/{libX11.so.6,libX11.a}
    rm "$FFBUILD_PREFIX"/lib/libX11{,-xcb}{.so*,.la}
}

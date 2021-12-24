#!/bin/bash
set -e

if [[ $# != 2 ]]; then
    echo "Missing arguments"
    exit -1
fi

if [[ -z "$GITHUB_REPOSITORY" || -z "$GITHUB_TOKEN" || -z "$GITHUB_ACTOR" ]]; then
    echo "Missing environment"
    exit -1
fi

INPUTS="$1"
TAGNAME="$2"

WIKIPATH="tmp_wiki"
WIKIFILE="Home.md"
git clone "https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.wiki.git" "${WIKIPATH}"

echo "# Latest Autobuilds\n**[What do the different builds mean?](#build-variants)**" > "${WIKIPATH}/${WIKIFILE}"
for f in "${INPUTS}"/*.txt; do
    VARIANT="$(basename "${f::-4}")"
    echo >> "${WIKIPATH}/${WIKIFILE}"
    echo "[${VARIANT}](https://github.com/${GITHUB_REPOSITORY}/releases/download/${TAGNAME}/$(cat "${f}"))" >> "${WIKIPATH}/${WIKIFILE}"
done


echo "
# Build Variants

Targets:
* \`win64\`: 64-bit Windows (x86_64) 
* \`win32\`: 32-bit Windows (x86)
* \`linux64\`: 64-bit Linux (x86_64, glibc>=2.23, linux>=4.4)

Variants:
* \`gpl\`: Includes all dependencies, even those that require full GPL instead of just LGPL 
* \`lgpl\`: Lacking libraries that are GPL-only. Most prominently libx264 and libx265.
* \`gpl-shared\`: Same as gpl, but comes with the libav* family of shared libs instead of pure static executables.
* \`lgpl-shared\`: Same again, but with the lgpl set of dependencies.
Extra:
* \`4.4\`: built from the ffmpeg 4.4 release branch instead of ffmpeg master.
" > "${WIKIPATH}/${WIKIFILE}"


cd "${WIKIPATH}"
git config user.email "actions@github.com"
git config user.name "Github Actions"
git add "$WIKIFILE"
git commit -m "Update latest version info"
git push

cd ..
rm -rf "$WIKIPATH"

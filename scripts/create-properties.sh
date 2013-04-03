#!/bin/bash

# This file creates the properties file for jesterpm-build-tools

pushd `dirname $0` > /dev/null
cd ..
BUILDTOOLSDIR=`pwd`
popd > /dev/null

cat > $HOME/.jesterpm-build-tools.properties << EOF
jesterpm.buildtools.root=${BUILDTOOLSDIR}
EOF


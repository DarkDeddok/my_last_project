#!/bin/bash
set -eo pipefail
set -x

git clone  -v https://lbornovalov@bitbucket.org/openiam/kubernetes-docker-configuration.git
cd kubernetes-docker-configuration
git checkout "RELEASE-${OPENIAM_VERSION_NUMBER}"
./setup.sh

echo "If using aws or google, make sure to install the necessary CLI tools, \
      and set the corresponding environment variables.  See README.md in \
      the corresponding module, for details..."

sleep 100500

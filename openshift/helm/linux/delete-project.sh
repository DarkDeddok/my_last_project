#!/usr/bin/env bash

#uncomment to debug this script.
#set -x

. set_env.sh

oc delete project ${APP_NAME}

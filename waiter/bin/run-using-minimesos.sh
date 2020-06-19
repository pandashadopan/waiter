#!/usr/bin/env bash
# Usage: run-using-minimesos.sh [PORT]
#
# Examples:
#   run-using-minimesos.sh 9091
#   run-using-minimesos.sh
#
# Runs Waiter, configured to use minimesos, which is assumed to be running already.

export WAITER_PORT=${1:-9091}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

$(${MINIMESOS_CMD:-${DIR}/ci/minimesos} info | grep MINIMESOS)
EXIT_CODE=$?
if [ ${EXIT_CODE} -eq 0 ]
then
    export WAITER_MARATHON=${MINIMESOS_MARATHON%;}
    export WAITER_ZOOKEEPER_CONNECT_STRING=$(echo ${MINIMESOS_ZOOKEEPER} | awk -F/ '{print $3}')
    export GRAPHITE_SERVER_PORT=5555
    export JWKS_PORT=8040
    export JWKS_SERVER_URL="http://127.0.0.1:${JWKS_PORT}/keys"
    export WAITER_TEST_JWT_ACCESS_TOKEN_URL="http://127.0.0.1:${JWKS_PORT}/get-token?host={HOST}"
    echo "WAITER_MARATHON = ${WAITER_MARATHON}"
    echo "WAITER_ZOOKEEPER_CONNECT_STRING = ${WAITER_ZOOKEEPER_CONNECT_STRING}"
else
    echo "Could not get Marathon URI from minimesos; you may need to restart minimesos"
    exit ${EXIT_CODE}
fi

echo "Starting waiter..."
cd ${DIR}/..
WAITER_AUTH_RUN_AS_USER=$(id -un) WAITER_LOG_FILE_PREFIX=${WAITER_PORT}- lein do clean, compile, run config-minimesos.edn

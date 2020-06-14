#!/bin/sh

set -eux

WS="$(dirname "$0")"
DOCKER_DIR="$(dirname "$(readlink -f "$0")")"

F="$DOCKER_DIR/Dockerfile"
if [ ! $F.in -ot $F ]; then
	sed -e "s|@@USER@@|$USER|g" $F.in > $F~
	mv $F~ $F
fi
IMAGE=$(sed -n -e 's|^FROM[ \t]\+\([^ \t]\+\).*|\1|p' "$F")

# TODO: infer $PD from $IMAGE
D="$WS/sources/docker/docker"
PD="$D/ubuntu/18.04"

if ! docker images | grep -q "$(echo "^$IMAGE:" | sed -e 's|:|[ \\t]\\+|g')"; then
	"$D/build.sh" "$PD"
fi

export DOCKER_DIR
exec "$PD/run.sh" "$DOCKER_DIR/run.sh" "$@"

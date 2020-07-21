#!/usr/bin/env sh

set -ue
set -x ## debug trace

case $1 in
  test)
    gocov test ./... | gocov report
    exit
    ;;
  linter)
    exec golangci-lint run ./...
    exit
    ;;
  air)
    shift
    exec air "$@"
    exit
    ;;
  delve)
    shift
    CGO_ENABLED=0 go build -x -gcflags="-N -l" -o main .
    chmod +x ./main
    dlv --listen=:40000 --headless=true --api-version=2 --accept-multiclient --log exec ./main -- "$@"
    exit
    ;;
esac

exec "$@"
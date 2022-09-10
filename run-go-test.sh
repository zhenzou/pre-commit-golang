#!/bin/bash
go test ./... --short

ret=$?
if [ $ret -ne 0 ]; then
  echo "tests failed"
  exit 1
fi
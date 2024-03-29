#!/bin/sh
#
# Generates Red Hat identity header and plain HTTP authorization.
#
une="$(uname -s)"
case "${une}" in
  Linux*)     B64OPTS="-w0";;
  Darwin*)    B64OPTS="-b0";;
  *)          echo "Unknown system ${une}" && exit 1
esac

JSON=$(
cat<<EOF
{"identity":{"type":"User","account_number":"$1","org_id":"$2","user":{"username":"user","email":"user@example.com","first_name":"User","last_name":"User"}}}
EOF
)

if [ -n "${1}" ] && [ -n "${2}" ]; then
  IDENTITY=$(echo "$JSON" | base64 $B64OPTS)
  echo "X-RH-Identity: $IDENTITY"
fi

if [ -n "${3}" ] && [ -n "${4}" ]; then
  echo "Authorization: Basic $(echo "$3:$4\c" | base64 $B64OPTS)"
fi

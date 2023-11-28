#!/bin/bash
PASSWORD=$(kubectl get secret awx-admin-password -o jsonpath='{.data.password}' -n awx | base64 --decode; echo)
echo "{\"password\": \"$PASSWORD\"}"

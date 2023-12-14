#!/bin/bash
PASSWORD=$(kubectl get secret awx-admin-password -o jsonpath='{.data.password}' -n awx | base64 --decode; echo)
IP=$(kubectl get ingress awx-ingress -n awx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "{\"password\": \"$PASSWORD\", \"ip\": \"$IP\"}"

#!/bin/bash
terraform output -json | jq -r 'to_entries[] | .key + "=" + (.value.value | tostring)' | while read -r line ; do echo export "$line"; done > env.sh
source env.sh
scp -i mainkey.pem mainkey.pem ubuntu@${BastionHost}:/home/ubuntu

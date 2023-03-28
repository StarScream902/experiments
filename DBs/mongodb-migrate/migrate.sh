#!/usr/bin/env bash

# apt update && apt install -y jq

# mongodump --help

# db_list=$(mongo "${src_db}" --quiet --eval "printjson(db.adminCommand('listDatabases'))" | jq  '.databases[].name' | tr -d '"')

# exclude_dbs='(admin|config|local)'
# for db in ${db_list}; do
#   if [[ ! "${db}" =~ $exclude_dbs ]]; then
#     echo "dumping the ${db} db"
#     mongodump "${src_db}" --authenticationDatabase=admin --db ${db} --gzip --out ./mongodump
#   fi
# done

mongorestore "${dst_db}" --gzip --drop --dir=./mongodump/

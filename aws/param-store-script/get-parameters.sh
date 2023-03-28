
aws ssm get-parameters-by-path \
    --profile  \
    --recursive \
    --with-decryption \
    --path /dev/chat | jq '.Parameters[] | (.Name | split("/") | .[4]) + ": " + .Value' | sed 's/"//g'

# AWS_PROFILE=main ./config.py /dev/chat

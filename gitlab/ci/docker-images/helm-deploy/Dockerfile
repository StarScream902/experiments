FROM alpine/helm:3.8.1

WORKDIR /tmp

RUN apk add python3 py3-pip git && mkdir ~/.aws

COPY ./requirements.txt .

RUN pip3 install -r ./requirements.txt

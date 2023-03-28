FROM mongo:4.4-focal

RUN set -eux; \
  apt-get update; \
  apt install -y \
    s3cmd \
    curl \
    python3 \
    python3-pip \
    jq; \
  mkdir ~/.aws; \
  rm -rf /var/lib/apt/lists/*

COPY ./requirements.txt .

RUN pip3 install -r ./requirements.txt

WORKDIR /backup

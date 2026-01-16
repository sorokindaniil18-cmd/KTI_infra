#!/usr/bin/env bash

REPO_USER=sorokindaniil-18cmd
GREEN='\033[92m'
RED='\033[91m'
NC='\033[0m'
STARTTIME=$(date +%s)
function date_f {
    date "+%d.%m.%Y %H:%M:%S"
}

function generate_secret {
    secret=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 24; echo)
    echo "$secret" > db_password
    red_text "Database password: $secret"
}

function green_text() {
    printf "${GREEN}%s${NC}\n" "$1$2"
}

function red_text() {
    printf "${RED}%s${NC}\n" "$1$2"
}

function rainbow_text() {
    TEXT="$1"
    COLORS=('\033[91m' '\033[92m' '\033[93m' '\033[94m' '\033[95m' '\033[96m')
    for ((i=0; i<${#TEXT}; i++)); do
        printf "${COLORS[i % ${#COLORS[@]}]}%s${NC}" "${TEXT:i:1}"
    done
    printf "\n"
}

green_text "$(date_f) " "Cleanup started"

existing_containers=$(docker container ls -aq)
if [ -n "$existing_containers" ]; then
    running_containers=$(docker container ls -q)
    if [ -n "$running_containers" ]; then
        docker container stop $running_containers
    fi
    docker container rm $existing_containers
fi

docker buildx prune -af

all_images=$(docker image ls -aq)
if [ -n "$all_images" ]; then
    docker image rm -f $all_images
fi

all_volumes=$(docker volume ls -q)
if [ -n "$all_volumes" ]; then
    docker volume rm $all_volumes
fi

rm -rf ~/KTI_infra
green_text "$(date_f) " "Cleanup finished"
green_text "$(date_f) " "Cloning infrastructure from repo"

git clone https://github.com/$REPO_USER/KTI_infra.git
cd KTI_infra

green_text "$(date_f) " "Cloning project files from repo"
git clone https://github.com/$REPO_USER/flask_project.git
green_text "$(date_f) " "Starting containers"

generate_secret
docker compose up -d
elapsed=$(( $(date +%s) - STARTTIME ))
green_text "$(date_f) Infrastructure ready"
rainbow_text "$(date_f) Time elapsed: ${elapsed} seconds"
exit 0

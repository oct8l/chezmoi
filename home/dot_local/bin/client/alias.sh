#!/usr/bin/env bash

# run gcloud command in docker container
alias gcloud='docker run --rm -it -v "${HOME%/}"/.config/gcloud:/root/.config/gcloud gcr.io/google.com/cloudsdktool/cloud-sdk gcloud'


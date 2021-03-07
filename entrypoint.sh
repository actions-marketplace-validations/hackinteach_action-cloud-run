#!/bin/sh

set -e

echo "$INPUT_SERVICE_KEY" | base64 --decode > "$HOME"/gcloud.json

if [ "$INPUT_ENV" ]
then
    ENVS=$(cat "$INPUT_ENV" | xargs | sed 's/ /,/g')
fi


if [ "$ENVS" ]
then
    ENV_FLAG="--set-env-vars $ENVS"
else
    ENV_FLAG="--clear-env-vars"
fi

if ["$INPUT_MIN_INSTANCES"]
then
  ENG_FLAG="--min-instances=$INPUT_MIN_INSTANCES $ENV_FLAG"
fi

if ["$INPUT_CLOUD_SQL"]
then
    ENV_FLAG="--add-cloudsql-instances $INPUT_CLOUD_SQL --update-env-vars INSTANCE_CONNECTION_NAME=$INPUT_CLOUD_SQL $ENV_FLAG"
fi

gcloud auth activate-service-account --key-file="$HOME"/gcloud.json --project "$INPUT_PROJECT"
gcloud auth configure-docker

docker push "$INPUT_IMAGE"

gcloud beta run deploy "$INPUT_SERVICE" \
  --image "$INPUT_IMAGE" \
  --region "$INPUT_REGION" \
  --platform managed \
  --allow-unauthenticated \
  ${ENV_FLAG}

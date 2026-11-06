#!/bin/sh

# Entrypoint for the docker container, generates the configuration on-the-fly from the template and runtime environment variables

# shellcheck disable=SC2086
GLOBAL_ENV=1 make clean frogservice.toml && exec clam --config frogservice.toml $CLAM_EXTRA

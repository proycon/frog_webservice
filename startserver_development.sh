#!/bin/bash
if [ ! -z "$VIRTUAL_ENV" ]; then
    pip3 install -e .
else
    echo "No virtual environment detected, you have to take care of running pip install yourself!">&2
fi
CLAM_HOST=localhost CLAM_PORT=8080 clamservice -d frog_webservice.frog_webservice

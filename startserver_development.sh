#!/bin/bash
if [ ! -z "$VIRTUAL_ENV" ]; then
    python setup.py develop
else
    echo "No virtual environment detected, you have to take care of running python setup.py install or setup.py develop yourself!">&2
fi
CLAM_HOST=localhost CLAM_PORT=8080 clamservice -d frog_webservice.frog_webservice

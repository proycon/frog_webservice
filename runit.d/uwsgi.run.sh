#!/bin/sh

# This script is meant to be invoked via runit (installed in /etc/service/nginx/run), not directly

uwsgi --plugin python3 \
      --uid 100 \
      --master \
      --socket "127.0.0.1:8888" \
      --wsgi-file /etc/frog_webservice.wsgi \
      --processes $UWSGI_PROCESSES \
      --threads $UWSGI_THREADS
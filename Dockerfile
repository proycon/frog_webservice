FROM proycon/frog
LABEL org.opencontainers.image.authors="Maarten van Gompel <proycon@anaproy.nl>"
LABEL description="Frog - A Tagger-Lemmatizer-Morphological-Analyzer-Dependency-Parser for Dutch, container image with webservice/webapp"

ARG UWSGI_PROCESSES=2
ENV UWSGI_PROCESSES=$UWSGI_PROCESSES
ARG UWSGI_THREADS=2
ENV UWSGI_THREADS=$UWSGI_THREADS

# By default, data from the webservice will be stored on the mount you provide
ARG CLAM_ROOT=/data/frog
ENV CLAM_ROOT=$CLAM_ROOT
ARG CLAM_PORT=80
ENV CLAM_PORT=$CLAM_PORT
# (set to true or false, enable this if you run behind a properly configured reverse proxy only)
ARG CLAM_USE_FORWARDED_HOST=false
ENV CLAM_USE_FORWARDED_HOST=$CLAM_USE_FORWARDED_HOST
# Set this for interoperability with the CLARIN Switchboard
ARG CLAM_SWITCHBOARD_FORWARD_URL=""
ENV CLAM_SWITCHBOARD_FORWARD_URL=$CLAM_SWITCHBOARD_FORWARD_URL


# Install all global dependencies
RUN apk update && apk add runit curl ca-certificates nginx uwsgi uwsgi-python3 py3-pip py3-yaml py3-lxml py3-requests

# Prepare environment
RUN mkdir -p /etc/service/nginx /etc/service/uwsgi

# Patch to set proper mimetype for CLAM's logs; maximum upload size
RUN sed -i 's/txt;/txt log;/' /etc/nginx/mime.types &&\
    sed -i 's/xml;/xml xsl;/' /etc/nginx/mime.types &&\
    sed -i 's/client_max_body_size 1m;/client_max_body_size 1000M;/' /etc/nginx/nginx.conf

# Temporarily add the sources of this webservice
COPY . /usr/src/webservice

# Configure webserver and uwsgi server
RUN cp /usr/src/webservice/runit.d/nginx.run.sh /etc/service/nginx/run &&\
    chmod a+x /etc/service/nginx/run &&\
    cp /usr/src/webservice/runit.d/uwsgi.run.sh /etc/service/uwsgi/run &&\
    chmod a+x /etc/service/uwsgi/run &&\
    cp /usr/src/webservice/frog_webservice/frog_webservice.wsgi /etc/frog_webservice.wsgi &&\
    chmod a+x /etc/frog_webservice.wsgi &&\
    cp -f /usr/src/webservice/frog_webservice.nginx.conf /etc/nginx/http.d/default.conf

# Install the the service itself (and foliatools for FoLiA XML visualisation)
RUN cd /usr/src/webservice && pip install . && rm -Rf /usr/src/webservice
RUN ln -s /usr/lib/python3.*/site-packages/clam /opt/clam

VOLUME ["/data"]
EXPOSE 80
WORKDIR /

ENTRYPOINT ["runsvdir","-P","/etc/service"]

FROM proycon/frog
LABEL org.opencontainers.image.authors="Maarten van Gompel <proycon@anaproy.nl>"
LABEL description="Frog - A Tagger-Lemmatizer-Morphological-Analyzer-Dependency-Parser for Dutch, container image with webservice/webapp"

ENV UWSGI_UID=100
ENV UWSGI_GID=100
ENV UWSGI_PROCESSES=2
ENV UWSGI_THREADS=2

# By default, data from the webservice will be stored on the mount you provide
ENV CLAM_ROOT=/data/frog
ENV CLAM_PORT=80
# (set to true or false, enable this if you run behind a properly configured reverse proxy only)
ENV CLAM_USE_FORWARDED_HOST=false
# Set this for interoperability with the CLARIN Switchboard
ENV CLAM_SWITCHBOARD_FORWARD_URL=""

# By default, there is no authentication on the service,
# which is most likely not what you want if you aim to
# deploy this in a production environment.
# You can connect your own Oauth2/OpenID Connect authorization by setting the following environment parameters:
ENV CLAM_OAUTH=false
#^-- set to true to enable
ENV CLAM_OAUTH_AUTH_URL=""
#^-- example for clariah: https://authentication.clariah.nl/Saml2/OIDC/authorization
ENV CLAM_OAUTH_TOKEN_URL=""
#^-- example for clariah https://authentication.clariah.nl/OIDC/token
ENV CLAM_OAUTH_USERINFO_URL=""
#^--- example for clariah: https://authentication.clariah.nl/OIDC/userinfo
ENV CLAM_OAUTH_CLIENT_ID=""
ENV CLAM_OAUTH_CLIENT_SECRET=""
#^-- always keep this private!

# Install all global dependencies
RUN apk update && apk add runit curl ca-certificates nginx uwsgi uwsgi-python3 py3-pip py3-yaml py3-lxml py3-requests py3-numpy py3-wheel

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

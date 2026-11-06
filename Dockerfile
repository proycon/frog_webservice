FROM alpine:latest
LABEL org.opencontainers.image.authors="Maarten van Gompel <proycon@anaproy.nl>"
LABEL description="Frog - A Tagger-Lemmatizer-Morphological-Analyzer-Dependency-Parser for Dutch, container image with webservice/webapp"

# By default, there is no authentication on the service,
# which is most likely not what you want if you aim to
# deploy this in a production environment.
# You can connect your own Oauth2/OpenID Connect authorization by setting the following environment parameters
# *AND* mounting files you references here into the container
ENV CLAM_OIDC_CONFIG_FILE=""

# Same for HTTP Basic Authentication:
ENV CLAM_USER_FILE=""

ENV CLAM_URL="http://127.0.0.1:8080"
ENV CLAM_ROOT="./data"

ENV CLAM_LISTEN="0.0.0.0:8080"
ENV CLAM_TERMS_OF_SERVICE=""

# You can use this to set extra parameters to CLAM like --debug
ENV CLAM_EXTRA=""

# Install all global dependencies, we take Frog from Alpine's repos as well
RUN apk update && apk add make cargo git envsubst curl ca-certificates nginx python3 py3-pip py3-lxml py3-requests py3-wheel zip frog
RUN cargo install --root /usr --git https://codeberg.org/proycon/clam --branch clam-4.0

# Temporarily add the sources of this webservice
COPY . /var/webservice

ENV HOME=/var/webservice
WORKDIR /var/webservice

# Install the service itself and cleanup unneeded sources afterwards, also add foliatools for visualisation
RUN cd /var/webservice && GLOBAL_ENV=1 make install-dependencies && chown 1000:1000 /var/webservice && rm -rf /var/webservice/local.env /root/.cache /root/.cargo && apk del cargo

VOLUME ["/data"]
EXPOSE 8080
WORKDIR /

ENTRYPOINT ["./entrypoint.sh"]

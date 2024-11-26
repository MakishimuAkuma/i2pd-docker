FROM alpine:latest AS builder

ARG GIT_BRANCH="openssl"
ENV GIT_BRANCH=${GIT_BRANCH}
ARG GIT_TAG=""
ENV GIT_TAG=${GIT_TAG}
ARG REPO_URL="https://github.com/PurpleI2P/i2pd.git"
ENV REPO_URL=${REPO_URL}

RUN apk update && apk --no-cache --virtual build-dependendencies add \
		make gcc g++ libtool zlib-dev boost-dev build-base \
		openssl-dev openssl miniupnpc-dev cmake git

RUN mkdir -p /tmp/build \
	&& cd /tmp/build \
	&& git clone -b ${GIT_BRANCH} ${REPO_URL} \
	&& cd i2pd \
	&& if [ -n "${GIT_TAG}" ]; then git checkout tags/${GIT_TAG}; fi \
	&& cd build \
	&& cmake -D CMAKE_BUILD_TYPE=Release -D WITH_UPNP=ON -D WITH_AVX=ON \
	&& make -j$(nproc)


FROM alpine:latest

WORKDIR /opt/i2pd

RUN apk update && apk --no-cache --virtual add boost-filesystem boost-system \
	boost-program_options boost-date_time boost-thread \
	boost-iostreams openssl miniupnpc musl-utils libstdc++

RUN addgroup i2pd && adduser -S i2pd -G i2pd

RUN mkdir -p /opt/i2pd/data /opt/i2pd/conf /var/lib/i2pd \
    && chown -R i2pd:i2pd /opt/i2pd && chown -R i2pd:i2pd /var/lib/i2pd

COPY --from=0 --chown=i2pd:i2pd /tmp/build/i2pd/build/i2pd /opt/i2pd/i2pd
COPY --from=0 --chown=i2pd:i2pd /tmp/build/i2pd/contrib/i2pd.conf /var/lib/i2pd/i2pd.conf
COPY --from=0 --chown=i2pd:i2pd /tmp/build/i2pd/contrib/tunnels.conf /var/lib/i2pd/tunnels.conf
COPY --from=0 --chown=i2pd:i2pd /tmp/build/i2pd/contrib/subscriptions.txt /var/lib/i2pd/subscriptions.txt
COPY --from=0 --chown=i2pd:i2pd /tmp/build/i2pd/contrib/certificates /var/lib/i2pd/certificates

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 7070 4444 4447 7656 2827 7654 7650

USER i2pd

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "--conf", "/opt/i2pd/conf/i2pd.conf", "--tunconf", "/opt/i2pd/conf/tunnels.conf", "--datadir", "/opt/i2pd/data" ]

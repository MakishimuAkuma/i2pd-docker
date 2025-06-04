FROM alpine:latest AS builder

RUN apk --update --no-cache --virtual build-dependendencies add \
		make gcc g++ libtool zlib-dev boost-dev build-base \
		openssl-dev openssl miniupnpc-dev cmake git

COPY ./i2pd ./i2pd

RUN cd i2pd/build \
	&& cmake -D CMAKE_BUILD_TYPE=Release -D WITH_UPNP=ON -D WITH_AVX=ON \
	&& make -j$(nproc)

FROM alpine:latest

WORKDIR /opt/i2pd

RUN apk --update --no-cache --virtual add boost-filesystem boost-system \
	boost-program_options boost-date_time boost-thread \
	boost-iostreams openssl miniupnpc musl-utils libstdc++

RUN mkdir -p /opt/i2pd/data /opt/i2pd/conf /var/lib/i2pd

COPY --from=builder /tmp/build/i2pd/build/i2pd /opt/i2pd/i2pd
COPY --from=builder /tmp/build/i2pd/contrib/i2pd.conf /var/lib/i2pd/i2pd.conf
COPY --from=builder /tmp/build/i2pd/contrib/tunnels.conf /var/lib/i2pd/tunnels.conf
COPY --from=builder /tmp/build/i2pd/contrib/subscriptions.txt /var/lib/i2pd/subscriptions.txt
COPY --from=builder /tmp/build/i2pd/contrib/certificates /var/lib/i2pd/certificates

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 7070 4444 4447 7656 2827 7654 7650

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "--conf", "/opt/i2pd/conf/i2pd.conf", "--tunconf", "/opt/i2pd/conf/tunnels.conf", "--datadir", "/opt/i2pd/data", "--loglevel", "error" ]

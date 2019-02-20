FROM debian:stretch-slim

RUN groupadd -r particl && useradd -r -m -g particl particl

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates dirmngr gosu wget \
	&& rm -rf /var/lib/apt/lists/*

ENV PARTICL_VERSION 0.18.0.3
ENV PARTICL_URL https://github.com/particl/particl-core/releases/download/v0.18.0.3alpha/particl-0.18.0.3-x86_64-linux-gnu.tar.gz
ENV PARTICL_SHA256 203f0133323faed3c1381fc833989a756e87d08708dc77374d78397416fb9b96

# install particl binaries
RUN set -ex \
	&& cd /tmp \
	&& wget -qO particl.tar.gz "$PARTICL_URL" \
	&& echo "$PARTICL_SHA256 particl.tar.gz" | sha256sum -c - \
	&& tar -xzvf particl.tar.gz -C /usr/local --strip-components=1 --exclude=*-qt \
	&& rm -rf /tmp/*

# create data directory
ENV PARTICL_DATA /data
RUN mkdir "$PARTICL_DATA" \
	&& chown -R particl:particl "$PARTICL_DATA" \
	&& ln -sfn "$PARTICL_DATA" /home/particl/.particl \
	&& chown -h particl:particl /home/particl/.particl
VOLUME /data

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 51735 51738 51935 51938 51936 11938
CMD ["particld"]
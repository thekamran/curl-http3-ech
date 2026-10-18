# curl with ECH (Encrypted Client Hello) + HTTP/3 (ngtcp2/nghttp3)
# TLS backend: OpenSSL 4.0 (ECH built in, QUIC TLS API usable by ngtcp2)

ARG OPENSSL_TAG=openssl-4.0.0
ARG NGHTTP3_TAG=v1.11.0
ARG NGTCP2_TAG=v1.14.0
ARG CURL_TAG=curl-8_19_0

############################ build stage ############################
FROM debian:bookworm AS build
ARG OPENSSL_TAG NGHTTP3_TAG NGTCP2_TAG CURL_TAG

RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential git ca-certificates perl pkg-config \
      autoconf automake libtool \
      zlib1g-dev libnghttp2-dev \
 && rm -rf /var/lib/apt/lists/*

ENV PREFIX=/opt/curl
ENV PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig
ENV LDFLAGS="-Wl,-rpath,$PREFIX/lib"
WORKDIR /src

# 1) OpenSSL with ECH
RUN git clone --depth 1 --branch $OPENSSL_TAG https://github.com/openssl/openssl \
 && cd openssl \
 && ./config --prefix=$PREFIX --libdir=lib no-docs \
 && make -j"$(nproc)" && make install_sw

# 2) nghttp3 (HTTP/3)
RUN git clone --depth 1 --branch $NGHTTP3_TAG --recursive https://github.com/ngtcp2/nghttp3 \
 && cd nghttp3 && autoreconf -fi \
 && ./configure --prefix=$PREFIX --enable-lib-only \
 && make -j"$(nproc)" && make install

# 3) ngtcp2 (QUIC) on top of OpenSSL
RUN git clone --depth 1 --branch $NGTCP2_TAG --recursive https://github.com/ngtcp2/ngtcp2 \
 && cd ngtcp2 && autoreconf -fi \
 && ./configure --prefix=$PREFIX --enable-lib-only --with-openssl \
 && make -j"$(nproc)" && make install

# 4) curl with ECH + HTTPS-RR + HTTP/3
RUN git clone --depth 1 --branch $CURL_TAG https://github.com/curl/curl \
 && cd curl && autoreconf -fi \
 && ./configure --prefix=$PREFIX \
      --with-openssl=$PREFIX \
      --with-ngtcp2=$PREFIX --with-nghttp3=$PREFIX \
      --with-nghttp2 \
      --enable-ech --enable-httpsrr \
      --without-libpsl \
      --with-ca-bundle=/etc/ssl/certs/ca-certificates.crt \
 && make -j"$(nproc)" && make install

############################ runtime stage ############################
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates zlib1g libnghttp2-14 \
 && rm -rf /var/lib/apt/lists/*

COPY --from=build /opt/curl /opt/curl
ENV PATH=/opt/curl/bin:$PATH

ENTRYPOINT ["curl"]
CMD ["-V"]

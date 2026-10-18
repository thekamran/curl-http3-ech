# curl-http3-ech

A minimal Docker image that ships a `curl` binary built with:

- **ECH** (Encrypted Client Hello) — hides the SNI from passive observers
- **HTTPS-RR** — resolves HTTPS DNS records to pick up ECH configs automatically
- **HTTP/3 (QUIC)** — via ngtcp2 + nghttp3 on top of OpenSSL's QUIC TLS API

| Component | Version |
|-----------|---------|
| OpenSSL   | 4.0.0   |
| nghttp3   | 1.11.0  |
| ngtcp2    | 1.14.0  |
| curl      | 8.19.0  |

## Pull

**GitHub Container Registry:**

```sh
docker pull ghcr.io/thekamran/curl-http3-ech:latest
```

**Docker Hub:**

```sh
docker pull 1kamran/curl-http3-ech:latest
```

## Usage

Print version and enabled features:

```sh
docker run --rm 1kamran/curl-http3-ech:latest -V
```

Test ECH — uses DoH to fetch the HTTPS RR (which carries the ECHConfig) then
connects with ECH enabled. `defo.ie` is a reliable ECH test target:

```sh
docker run --rm 1kamran/curl-http3-ech:latest \
  -sv --ech hard \
  --doh-url https://1.1.1.1/dns-query \
  https://defo.ie/ech-check.php
```

A successful response contains `SSL_ECH_STATUS: success`.

Test HTTP/3 (QUIC):

```sh
docker run --rm 1kamran/curl-http3-ech:latest \
  --http3-only -sv \
  https://cloudflare.com/
```

## Build locally

```sh
docker build -t curl-http3-ech .
```

Override component versions at build time:

```sh
docker build \
  --build-arg OPENSSL_TAG=openssl-4.0.0 \
  --build-arg NGHTTP3_TAG=v1.11.0 \
  --build-arg NGTCP2_TAG=v1.14.0 \
  --build-arg CURL_TAG=curl-8_19_0 \
  -t curl-http3-ech .
```

## Image details

- **Base**: `debian:bookworm-slim` (runtime), `debian:bookworm` (build)
- **Entrypoint**: `curl`
- **Default command**: `-V` (print version and enabled features)
- All runtime libraries are copied to `/opt/curl`; `PATH` is updated automatically.

## License

The Dockerfile is released under the [MIT-0 License](LICENSE). The bundled
software (curl, OpenSSL, ngtcp2, nghttp3) retains its own respective licenses.

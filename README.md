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

Run a basic request:

```sh
docker run --rm 1kamran/curl-http3-ech:latest -V
```

Test ECH against Cloudflare:

```sh
docker run --rm 1kamran/curl-http3-ech:latest \
  --ech hard --doh-url https://1.1.1.1/dns-query \
  https://cloudflare.com
```

Test HTTP/3:

```sh
docker run --rm 1kamran/curl-http3-ech:latest \
  --http3 https://cloudflare.com
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

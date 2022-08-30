# Extended Alpine Linux Docker image

`alpine:latest` extended by the `gettext` package (provides `envsubst` command). The container (specifically, `envsubst`) is used in https://github.com/MaRDI4NFDI/portal-compose to set up configuration files from environment variables. See [man envsubst](https://www.man7.org/linux/man-pages/man1/envsubst.1.html).

This is required to setup, e.g., prometheus and grafana.

# Build instructions

Build with:
```
docker build . -t alpine-ext
```

# docker-compose examples

Example usage for prometheus/grafana (see https://github.com/MaRDI4NFDI/portal-compose/blob/main/docker-compose.yml)

```yaml
services:
  [...]
  
  setup_prometheus:
    image: "ghcr.io/mardi4nfdi/docker-alpine-ext:main"
    volumes:
      - ./prometheus/:/etc/prometheus/:rw
    command: sh -c "envsubst < /etc/prometheus/prometheus.template.yml > /etc/prometheus/prometheus.yml"
    environment:
      - TRAEFIK_USER
      - TRAEFIK_PW
      - HOST_NETWORK_IP
      - WATCHTOWER_API_TOKEN

  prometheus:
    image: prom/prometheus
    container_name: prometheus
    depends_on:
      - setup_prometheus
    restart: unless-stopped
    volumes:
      - ./prometheus/:/etc/prometheus/:ro
      - prometheus_data:/prometheus
    command:
      - --config.file=/etc/prometheus/prometheus.yml
      - --storage.tsdb.path=/prometheus
      - --web.console.libraries=/usr/share/prometheus/console_libraries
      - --web.console.templates=/usr/share/prometheus/consoles

  setup_grafana:
    image: "ghcr.io/mardi4nfdi/docker-alpine-ext:main"
    volumes:
      - ./grafana/:/etc/grafana/:rw
    command: sh -c "envsubst < /etc/grafana/grafana.template.ini > /etc/grafana/grafana.ini"
    environment:
      - GF_MAIL_HOST
      - GF_MAIL_USER
      - GF_MAIL_PW
      - GF_MAIL_FROMADDRESS
      - GF_MAIL_FROMNAME

  grafana:
    image: grafana/grafana
    depends_on:
      - setup_grafana
      - prometheus
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/:/etc/grafana/
```
assuming here that all environment variables defined for `setup_grafana` and `setup_prometheus` are set in the `.env` file.

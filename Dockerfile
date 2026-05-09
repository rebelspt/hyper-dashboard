FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl && rm -rf /var/lib/apt/lists/*
ARG TARGETARCH
COPY hyper-dashboard-linux-${TARGETARCH} /usr/local/bin/hyper-dashboard
COPY assets /usr/local/bin/assets
COPY config /usr/local/bin/config
RUN curl -sLo /usr/local/bin/assets/htmx.min.js https://unpkg.com/htmx.org@2.0.10/dist/htmx.min.js && \
    curl -sLo /usr/local/bin/assets/alpine.min.js https://cdn.jsdelivr.net/npm/alpinejs@3.15.12/dist/cdn.min.js
WORKDIR /usr/local/bin
EXPOSE 8080
ENTRYPOINT ["hyper-dashboard"]
CMD ["--host", "0.0.0.0", "--local-assets", "--config", "config/hyper-dashboard.yaml"]

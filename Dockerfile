FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*
ARG TARGETARCH
COPY hyper-dashboard-linux-${TARGETARCH} /usr/local/bin/hyper-dashboard
COPY assets /usr/local/bin/assets
COPY config /usr/local/bin/config
WORKDIR /usr/local/bin
EXPOSE 8080
ENTRYPOINT ["hyper-dashboard"]
CMD ["--host", "0.0.0.0", "--config", "config/hyper-dashboard.yaml"]

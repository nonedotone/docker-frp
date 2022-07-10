FROM golang:1.18-alpine AS build

ENV CGO_ENABLED=0
ENV GO111MODULE=on
ENV FRP_VERSION=v0.43.0

WORKDIR /

RUN apk update && apk add --no-cache git && \
    git clone https://github.com/fatedier/frp.git && \
    cd /frp && mkdir bin && git checkout ${FRP_VERSION} && go mod tidy && \
    go build -trimpath -ldflags "-s -w" -o bin/frps ./cmd/frps && \
    go build -trimpath -ldflags "-s -w" -o bin/frpc ./cmd/frpc


FROM alpine:latest

LABEL name="none" email="none@none.one"

WORKDIR /frp

COPY --from=build /frp/bin/frps /frp/frps
COPY --from=build /frp/bin/frpc /frp/frpc
COPY --from=build /frp/conf/frps.ini /frp/frps.ini
COPY --from=build /frp/conf/frpc.ini /frp/frpc.ini

CMD ["/frp/frpc", "-c", "/frp/frpc.ini"]
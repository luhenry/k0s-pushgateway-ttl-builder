FROM golang:1.26.2-alpine AS builder

RUN apk add git make curl

RUN git clone -b v1.4.0 https://github.com/dinumathai/pushgateway.git

WORKDIR pushgateway

ARG PROMU_VERSION=0.18.1
RUN sed -i 's/go 1.11/go 1.26.2/g' go.mod && \
    go get -u github.com/prometheus/client_golang@v1.11.1 && \
    go get -u github.com/prometheus/exporter-toolkit@v0.8.2  && \
    go get -u golang.org/x/crypto@v0.0.0-20220314234659-1baeb1ce4c0b && \
    go get -u golang.org/x/sys@v0.4.0 && \
    go get -u golang.org/x/net@v0.4.0 && \
    go mod tidy && go mod vendor && \
    make common-build

FROM alpine:3.22

COPY --from=builder /go/pushgateway/pushgateway /bin/pushgateway

USER 65534

ENTRYPOINT [ "/bin/pushgateway" ]

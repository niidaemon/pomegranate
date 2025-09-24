FROM golang:bookworm AS builder

WORKDIR /src

COPY go.mod ./
RUN go mod download

COPY . .

ARG TARGETOS=linux
ARG TARGETARCH=amd64
ENV CGO_ENABLED=0
ENV GOOS=${TARGETOS}
ENV GOARCH=${TARGETARCH}

RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
    go build -ldflags="-s -w" -o /out/server .

FROM scratch AS runtime
COPY --from=builder /out/server /server
EXPOSE 8004
ENTRYPOINT ["/server"]

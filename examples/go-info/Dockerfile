FROM golang:1.9.1-alpine as builder
WORKDIR /go/src/go-info
COPY main.go .
RUN CGO_ENABLED=0 go build -a

FROM scratch
COPY --from=builder /go/src/go-info/go-info .
WORKDIR /
EXPOSE 8000
ENTRYPOINT ["/go-info"]

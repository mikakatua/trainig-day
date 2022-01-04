# build stage
FROM golang:1.17-alpine AS builder
# Build the app
WORKDIR /go/src/app
COPY main.go .
RUN go mod init && go build -o /app

# final stage
FROM alpine:3.15
COPY --from=builder /app /app
RUN touch /file.p12
EXPOSE 80
USER nobody
CMD ["/app"]

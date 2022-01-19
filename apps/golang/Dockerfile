# build stage
FROM golang:1.17-alpine AS builder
# Build the app
WORKDIR /go/src/app
COPY main.go .
RUN go mod init && go build -o /app

# final stage
FROM alpine:3.15
COPY --from=builder /app /app
EXPOSE 80
# Use a volume secret instead
#RUN touch /file.p12
CMD ["/app"]

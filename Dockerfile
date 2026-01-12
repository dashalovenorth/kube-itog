FROM golang:1.25-alpine AS builder

WORKDIR /app
COPY go.mod ./
RUN go mod download

COPY cmd/ ./cmd/

RUN CGO_ENABLED=0 GOOS=linux go build -o /root-service ./cmd/root-service
RUN CGO_ENABLED=0 GOOS=linux go build -o /api-service ./cmd/api-service
RUN CGO_ENABLED=0 GOOS=linux go build -o /info-service ./cmd/info-service
RUN CGO_ENABLED=0 GOOS=linux go build -o /login-service ./cmd/login-service

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/

COPY --from=builder /root-service ./
COPY --from=builder /api-service ./
COPY --from=builder /info-service ./
COPY --from=builder /login-service ./

EXPOSE 8080

CMD ["./root-service"]
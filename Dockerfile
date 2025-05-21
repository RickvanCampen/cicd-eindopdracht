# ---------- STAGE 1: Builder ----------
FROM golang:1.21-alpine AS builder

# Installeer build dependencies
RUN apk add --no-cache git sqlite

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod tidy && go mod download

COPY . .

WORKDIR /app/cmd
RUN go build -o /go/bin/app

# ---------- STAGE 2: Runtime ----------
FROM alpine:latest

# Installeer alleen runtime dependencies
RUN apk add --no-cache sqlite

WORKDIR /root/

COPY --from=builder /go/bin/app .

CMD ["./app"]

# ---------- STAGE 1: Builder ----------
FROM golang:1.21-alpine AS builder

# Installeer build dependencies
RUN apk add --no-cache git sqlite

WORKDIR /app

# Eerst alles kopiëren
COPY . .

# Pas daarna dependencies installeren
RUN go mod tidy && go mod download

WORKDIR /app/cmd

# Build de binary
RUN go build -o /go/bin/app

# ---------- STAGE 2: Runtime ----------
FROM alpine:latest

# Alleen runtime dependencies
RUN apk add --no-cache sqlite

WORKDIR /root/

COPY --from=builder /go/bin/app .

CMD ["./app"]

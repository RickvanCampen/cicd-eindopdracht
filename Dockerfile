# ---------- STAGE 1: Builder ----------
FROM golang:1.21-alpine AS builder

# Installeer build dependencies
RUN apk add --no-cache git sqlite

# Set working directory
WORKDIR /app

# Kopieer dependency files en download modules
COPY go.mod go.sum ./
RUN go mod tidy && go mod download

# Kopieer rest van de app
COPY . .

# Bouw de applicatie
WORKDIR /app/cmd
RUN go build -o /go/bin/app

# ---------- STAGE 2: Runtime ----------
FROM alpine:latest

# Installeer alleen runtime dependencies
RUN apk add --no-cache sqlite

# Set working directory
WORKDIR /root/

# Kopieer de binary vanuit de builder
COPY --from=builder /go/bin/app .

# Start de app
CMD ["./app"]

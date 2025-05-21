# ---------- STAGE 1: Builder ----------
FROM golang:1.21-alpine AS builder

# Voeg build arguments toe (alleen tijdens buildtijd beschikbaar)
ARG DB_NAME
ARG SECRET_KEY

# Zet ze als env vars als je ze in build nodig hebt
ENV DB_NAME=${DB_NAME}
ENV SECRET_KEY=${SECRET_KEY}

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

# Zet werkdirectory
WORKDIR /root/

# Kopieer de binary van de builder stage
COPY --from=builder /go/bin/app .

# Zet alleen runtime environment variabelen (hier geen ARG meer nodig!)
ENV DB_NAME=mijn_database.db
ENV SECRET_KEY=mijnSuperGeheimeSleutel123

# Start de app
CMD ["./app"]

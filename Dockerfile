# Stap 1: Gebruik een Go-alpine image voor de builder
FROM golang:1.21-alpine AS builder

# Stap 2: Installeer benodigde dependencies
RUN apk add --no-cache git sqlite

# Stap 3: Stel de werkdirectory in voor de buildfase
WORKDIR /go/src/app

# Stap 4: Kopieer go.mod en go.sum naar de container
COPY go.mod go.sum ./

# Stap 5: Haal de Go dependencies op
RUN go mod tidy && go mod download

# Stap 6: Kopieer de hele projectmap naar de container
COPY . .

# Stap 7: Stel de werkmap in voor de build van de main.go
WORKDIR /go/src/app/cmd

# Stap 8: Bouw de Go applicatie
RUN go build -o main .

# Stap 9: Maak een kleinere runtime image
FROM alpine:latest

# Stap 10: Installeer benodigde runtime dependencies
RUN apk add --no-cache sqlite

# Stap 11: Stel de werkdirectory in voor de runtime
WORKDIR /root/

# Stap 12: Kopieer de gebouwde binary van de builder naar de runtime image
COPY --from=builder /go/src/app/cmd/main /root/

# Stap 13: Stel de entrypoint in voor de applicatie
CMD ["./main"]


FROM golang:1.22-alpine3.19 AS alp

COPY . /github.com/azoma13/auth/
WORKDIR /github.com/azoma13/auth/

RUN go mod download
RUN go build -o ./bin/auth cmd/main.go

FROM alpine:latest

WORKDIR /root/
COPY --from=alp /github.com/azoma13/auth/bin/auth .

CMD [ "./auth" ]
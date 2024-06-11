LOCAL_BIN:=$(CURDIR)/bin 

install-deps:
	GOBIN=$(LOCAL_BIN) go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.34.1
	GOBIN=$(LOCAL_BIN) go install -mod=mod google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.4.0

get-deps:
	go get -u google.golang.org/protobuf/cmd/protoc-gen-go
	go get -u google.golang.org/grpc/cmd/protoc-gen-go-grpc

install-golangci-lint:
	GOBIN=$(LOCAL_BIN) go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.53.3

lint:
	GOBIN=$(LOCAL_BIN) golangci-lint run ./... --config .golangci.pipeline.yaml

generate-user-api:
	mkdir -p pkg/user_api_v1
	protoc --proto_path api/user_api_v1 \
	--go_out=pkg/user_api_v1 --go_opt=paths=source_relative \
	--plugin=protoc-gen-go=bin/protoc-gen-go \
	--go-grpc_out=pkg/user_api_v1 --go-grpc_opt=paths=source_relative \
	--plugin=protoc-gen-go-grpc=bin/protoc-gen-go-grpc \
	api/user_api_v1/user_api.proto

build:
	GOOS=linux GOARCH=amd64 go build -o bin/auth cmd/main.go

copy-to-server:
	scp bin/auth roxaneos@192.168.0.106:

docker-build-and-push:
	sudo docker buildx build --no-cache --platform linux/amd64 -t cr.selcloud.ru/azoma13/auth:v0.0.1 .
	sudo docker login -u token -p CRgAAAAAs-ERMFmrzVTcfyeJ3SXirZbkbqqdMevj cr.selcloud.ru/azoma13
	sudo docker push cr.selcloud.ru/azoma13/auth:v0.0.1
build: 
	docker build -t os161 .

run: 
	docker run --rm -it -v "$(PWD):/root/cs350-os161" --entrypoint /bin/bash os161:latest

.PHONY: build

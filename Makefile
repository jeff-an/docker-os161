image: 
	docker build -t os161 .

linux:
	docker run -it --rm -v "$(PWD):/root/cs350-os161" --entrypoint "/bin/bash" os161:latest

detachedlinux: image
	docker run -i -d --name os161-work -v "$(PWD):/root/cs350-os161" os161:latest

run: image
	docker run --rm -it -w "/root/cs350-os161/root" -v "$(PWD):/root/cs350-os161" --entrypoint sys161 os161:latest kernel

newkernel: detachedlinux
	docker exec -d os161-work /bin/bash bin/build-kernel.sh
	docker exec -it -w "/root/cs350-os161/root" os161-work sys161 kernel
	docker rm -f os161-work
		
newuser: detachedlinux
	docker exec -d os161-work /bin/bash bin/build-user.sh
	docker exec -it -w "/root/cs350-os161/root" os161-work sys161 kernel
	docker rm -f os161-work

newall: detachedlinux
	docker exec -d os161-work /bin/bash bin/build-kernel.sh
	docker exec -d os161-work /bin/bash bin/build-user.sh
	docker exec -it -w "/root/cs350-os161/root" os161-work sys161 kernel
	docker rm -f os161-work

.PHONY: image linux detachedlinux run newkernel newuser newall test

all: 
	docker build -t jottr/lamp . 

clean: 
	docker rmi jottr/lamp .
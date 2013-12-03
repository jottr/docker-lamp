imagename=jottr/lamp

build: 
	docker build -t $(imagename) .
	notify-send "Done building $(imagename)." 

clean: 
	docker rmi $(imagename)

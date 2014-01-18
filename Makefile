IMG:=jottr/$$(basename $$(pwd))

build:
	docker build -t $(IMG) .
	@notify-send "Done building $(IMG)"

clean:
	docker rmi $(IMG)

docker:
	docker build --no-cache -t proycon/frog_webservice:latest .

docker-dev:
	#builds with a development version of CLAM, not of Frog!
	docker build --no-cache -t proycon/frog_webservice:dev --build-arg CLAM_DEV=1 .

deps:
	./build-deps.sh

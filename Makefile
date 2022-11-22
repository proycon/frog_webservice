docker:
	docker build --no-cache -t proycon/frog_webservice:latest .

docker-dev:
	docker build --no-cache -t proycon/frog_webservice:dev --build-arg VERSION=development .

deps:
	./build-deps.sh
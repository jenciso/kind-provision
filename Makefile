provision:
	./scripts/provision-cluster.sh
	./scripts/provision-coreapps.sh

setup:
	./scripts/setup.sh

install: provision setup
	
destroy:
	./scripts/destroy.sh

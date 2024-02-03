install:
	./scripts/install-cluster.sh

setup:
	./scripts/setup-coreapps.sh
	./scripts/setup-baseapps.sh

provision: install setup
	
destroy:
	./scripts/destroy-cluster.sh

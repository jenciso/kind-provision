include .env
export

install: install-cluster install-registry install-registry-proxy

install-cluster:
	./scripts/install-cluster.sh

install-registry:
	./scripts/kind-registry.sh

install-registry-proxy:
	./scripts/registry-proxy.sh

setup:
	./scripts/setup-coreapps.sh
	./scripts/setup-baseapps.sh

uninstall:
	./scripts/uninstall.sh

provision: install setup
	
destroy:
	./scripts/destroy-cluster.sh

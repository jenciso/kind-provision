include .env
export

install: install-cluster install-local-registry install-registry-proxy

install-cluster:
	./scripts/install-cluster.sh

install-local-registry:
	./scripts/local-registry.sh

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

start-cluster:
	./scripts/start-cluster.sh

stop-cluster:
	./scripts/stop-cluster.sh

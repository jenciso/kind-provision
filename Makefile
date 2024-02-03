provision:
	./provision.sh

setup:
	./setup.sh

install: provision setup
	
destroy:
	./destroy.sh

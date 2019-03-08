# service name
# required by client
# this can be defined in commandline
#   make client service=something
service=
prefix=./client/$(service)

DAYS=3650
SERVER_SUBJECT="/C=AU/ST=Some State/O=example.com/OU=server/CN=server"
CLIENT_SUBJECT="/C=AU/ST=Some State/O=example.com/OU=client/CN=$(service)"

check-service:
ifndef service
	echo 'Service name must be given by "service=something" as parameter'
	exit 1
endif

server:
	mkdir -p server
	openssl genrsa -out ./server/ca.key 2048
	openssl req -new -x509 -key ./server/ca.key -out ./server/ca.crt -days $(DAYS) -subj $(SERVER_SUBJECT)

client: check-service
	mkdir -p $(prefix)
	openssl genrsa -out $(prefix)/key.pem 2048
	openssl req -new -key $(prefix)/key.pem -out $(prefix)/csr.pem -subj $(CLIENT_SUBJECT) -config ./conf/req.cnf
	openssl ca -config ./conf/ca.cnf -out $(prefix)/cert.pem -extfile ./conf/ext.cnf -in $(prefix)/csr.pem

	openssl verify -CAfile ./server/ca.crt $(prefix)/cert.pem

init:
	touch index.txt
	echo '01' > serial
	mkdir -p newcerts/

clean:
	rm -rf server/ client/ newcerts/ index.txt* serial*

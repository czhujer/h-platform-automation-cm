#!/bin/sh
umask 077

answers() {
	echo --
	echo SomeState
	echo SomeCity
	echo SomeOrganization
	echo SomeOrganizationalUnit
	echo localhost.localdomain
	echo root@localhost.localdomain
}

if [ $# -eq 0 ] ; then
	echo $"Usage: `basename $0` filename [...]"
	exit 0
fi

for target in $@ ; do
	PEM1=`/bin/mktemp /tmp/openssl.XXXXXX`
	PEM2=`/bin/mktemp /tmp/openssl.XXXXXX`
	trap "rm -f $PEM1 $PEM2" SIGINT
	answers | /usr/bin/openssl req -newkey rsa:2048 -keyout $PEM1 -nodes -x509 -days 365 -out $PEM2 2> /dev/null
	cat $PEM1 >  /etc/pki/tls/private/${target}.key
	cat $PEM2 > /etc/pki/tls/certs/${target}.crt
	chown root:root /etc/pki/tls/certs/${target}.crt /etc/pki/tls/private/${target}.key
	rm -f $PEM1 $PEM2
done

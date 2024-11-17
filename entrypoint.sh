#!/bin/sh
COMMAND=/opt/i2pd/i2pd

if [ "$1" = "--help" ]; then
    set -- $COMMAND --help
else
	cp -n /var/lib/i2pd/i2pd.conf /opt/i2pd/conf/i2pd.conf
	cp -n /var/lib/i2pd/tunnels.conf /opt/i2pd/conf/tunnels.conf
	cp -n /var/lib/i2pd/subscriptions.txt /opt/i2pd/data/subscriptions.txt
	cp -R -n /var/lib/i2pd/certificates /opt/i2pd/data/certificates
    set -- $COMMAND $DEFAULT_ARGS $@
fi

exec "$@"
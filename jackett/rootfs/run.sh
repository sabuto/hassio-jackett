#!/usr/bin/env bashio
declare port
declare certfile
declare hassio_dns
declare ingress_interface
declare ingress_port
declare ingress_entry
WAIT_PIDS=()

bashio::log.info "starting...."

ingress_entry=$(bashio::addon.ingress_entry)
ingress_port=$(bashio::addon.ingress_port)
ingress_interface=$(bashio::addon.ip_address)
sed -i "s/%%port%%/${ingress_port}/g" /etc/nginx/servers/ingress.conf
sed -i "s/%%interface%%/${ingress_interface}/g" /etc/nginx/servers/ingress.conf
sed -i "s#%%ingress_entry%%#${ingress_entry}#g" /etc/nginx/servers/ingress.conf

hassio_dns=$(bashio::dns.host)
sed -i "s/%%hassio_dns%%/${hassio_dns}/g" /etc/nginx/includes/resolver.conf

exec nginx &
WAIT_PIDS+=($!)

bashio::log.info "starting jackett"

if ! bashio::fs.directory_exists '/config/jackett'; then
	mkdir -p /config/jackett
	mkdir -p /share/jackett
fi

if ! bashio::fs.file_exists '/config/jackett/ServerConfig.json'; then
	mv /Jackett/ServerConfig.json /config/jackett/ServerConfig.json
fi

APIKEY=${APIKEY-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)}
INSTANCEID=${INSTANCEID-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 100 | head -n 1)}

sed -i 's/<apikey>/'${APIKEY}'/;s/<instanceid>/'${INSTANCEID}'/' /config/jackett/ServerConfig.json
sed -i "s#%%basepath%%#${ingress_entry}#g" /config/jackett/ServerConfig.json

cd /opt/Jackett || bashio::exit.nok "setup gone wrong!"

exec jackett --NoUpdates &
WAIT_PIDS+=($!)

function stop_addon() {
	bashio::log.info "Kill Processes..."
	kill -15 "${WAIT_PIDS[@]}"
	bashio::log.info "Done"
}

trap "stop_addon" SIGTERM SIGHUP

#Wait until all is done
bashio::log.info "All is running smoothly"
wait "${WAIT_PIDS[@]}"

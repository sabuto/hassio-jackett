#!/usr/bin/env bashio
declare port
declare certfile
declare hassio_dns
declare ingress_interface
declare ingress_port
declare ingress_entry
declare black_hole
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
	mkdir -p /config/Jackett || bashio::exit.nok "error in folder creation"
	mkdir -p /share/Jackett || bashio::exit.nok "error in folder creation 2"
fi

black_hole=$(bashio::config 'black_hole')

bashio::log.info "Black hole: ${black_hole}"

if ! bashio::fs.directory_exists "${black_hole}"; then
	mkdir -p $black_hole || bashio::exit.nok "error in folder creation 3"
fi

mv /Jackett/ServerConfig.json /config/Jackett/ServerConfig.json || bashio::exit.nok "error in config move"

sed -i "s#%%black_hole%%#${black_hole}#g" /config/Jackett/ServerConfig.json || bashio::exit.nok "error in blackhole sed"

sed -i "s#%%basepath%%#${ingress_entry}#g" /config/Jackett/ServerConfig.json || bashio::exit.nok "error in port sed"

cd /opt/Jackett || bashio::exit.nok "setup gone wrong!"

exec ./jackett --NoUpdates &
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

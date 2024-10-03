#!/bin/sh

orange="\e[38;5;208m%s\e[0m\n\n"
blue="\e[38;5;69m%s\e[0m\n"
green="\n\e[38;5;46m%s\e[0m\n"

printf $orange "Openwrt DNS over TLS Setup v1.0"
printf "Running opkg update"
opkg update > /dev/null
printf $blue "               DONE"

printf "Installing Stubby"
opkg install stubby > /dev/null
printf $blue "                 DONE"

printf "Stopping Dnsmasq"
service dnsmasq stop
printf $blue "                  DONE"

printf "Configuring Stubby"
uci set dhcp.@dnsmasq[0].noresolv="1"
uci -q delete dhcp.@dnsmasq[0].server
uci -q get stubby.global.listen_address \
| sed -e "s/\s/\n/g;s/@/#/g" \
| while read -r STUBBY_SERV
do uci add_list dhcp.@dnsmasq[0].server="${STUBBY_SERV}"
done
uci set dhcp.@dnsmasq[0].localuse="0"
printf $blue "                DONE"

printf "Saving configuration"
uci commit dhcp
printf $blue "              DONE"

printf "Starting Dnsmasq"
service dnsmasq start > /dev/null 2>&1
printf $blue "                  DONE"

printf $green "Setup Complete"
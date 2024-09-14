#!/usr/bin/env sh

login_server=$(if [ -n "$TAILSCALE_LOGIN_SERVER" ]; then echo "--login-server=$TAILSCALE_LOGIN_SERVER"; else echo ""; fi)
accept_routes=$(if [ "$TAILSCALE_ACCEPT_ROUTES" = "true" ]; then echo "--accept-routes=true"; else echo "--accept-routes=false"; fi)
accept_dns=$(if [ "$TAILSCALE_ACCEPT_DNS" = "true" ]; then echo "--accept-dns=true"; else echo "--accept-dns=false"; fi)
hostname=$(if [ -n "$TAILSCALE_HOSTNAME" ]; then echo "--hostname=$TAILSCALE_HOSTNAME"; else echo ""; fi)
advertise_tags=$(if [ -n "$TAILSCALE_ADVERTISE_TAGS" ]; then echo "--advertise-tags=$TAILSCALE_ADVERTISE_TAGS"; else echo ""; fi)

#Start tailscaled and connect to tailnet
/usr/sbin/tailscaled --state=/var/lib/tailscale/tailscaled.state >> /dev/stdout &
/usr/bin/tailscale up --auth-key $TAILSCALE_AUTH_KEY $login_server $accept_routes $accept_dns $hostname $advertise_tags >> /dev/stdout &

#Check for and or create certs directory
mkdir -p /root/derper/$TAILSCALE_DERP_HOSTNAME

#Start Tailscale derp server
/root/go/bin/derper --hostname $TAILSCALE_DERP_HOSTNAME --bootstrap-dns-names $TAILSCALE_DERP_HOSTNAME -certmode $TAILSCALE_DERP_CERTMODE -certdir /root/derper/$TAILSCALE_DERP_HOSTNAME --stun --verify-clients

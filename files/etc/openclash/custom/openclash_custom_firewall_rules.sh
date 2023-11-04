if [ "$en_mode" == "fake-ip" ]; then
  LOG_OUT "limit route to only fake ips with proxy port $proxy_port"
  
  /etc/mosdns/rule/geoip2ipset.sh /etc/openclash/GeoIP.dat telegram
  
  if [ -n "$FW4" ]; then
    handle=$(nft -a list chain inet fw4 openclash | grep 'ip protocol tcp counter' | awk '{print $NF}')
    LOG_OUT "deleting nft rule handle $handle"
    nft delete rule inet fw4 openclash handle $handle
    nft add rule inet fw4 openclash ip protocol tcp ip daddr @telegram counter redirect to $proxy_port
  else
    iptables -t nat -D openclash -p tcp -j REDIRECT --to-ports $proxy_port
    iptables -t nat -A openclash -m set --match-set telegram dst -p tcp -j REDIRECT --to-ports $proxy_port
  fi
fi

LOG_OUT "restart adguardhome"
/etc/init.d/AdGuardHome restart 

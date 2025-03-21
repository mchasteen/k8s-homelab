# Notes

I decided to try to setup bind (since I am somewhat familar with it) in my home lab and I wanted to see if external-dns could update it. I have found you can run two external-dns instances side by side.  The main issue wuth the bind deployment is making sure to sync the journal file and "freeze/thaw" before editing (use rndc sync -clean to clean the zone files).
 
# Links

https://grafana.com/grafana/dashboards/15038-external-dns/

# RFC2136

https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/rfc2136.md

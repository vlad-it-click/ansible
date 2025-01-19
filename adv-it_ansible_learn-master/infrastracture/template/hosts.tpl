[staging_servers]
${host_x} owner=Alex 

[prod_servers]
${host_1} ansible_user=${user_1} owner=Arcadii
${host_2} owner=IronMan

[all_servers:children]
staging_servers
prod_servers 

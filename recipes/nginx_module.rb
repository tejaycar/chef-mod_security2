node.run_state['nginx_configure_flags'] ||= []

node.run_state['nginx_configure_flags'] =
  node.run_state['nginx_configure_flags'] |
  ["--add-module=#{node['mod_security2']['home']}/nginx/modsecurity"]

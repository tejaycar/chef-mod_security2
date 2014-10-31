include_recipe 'mod_security2::install'

node.run_state['nginx_configure_flags'] ||= []
node.run_state['nginx_configure_flags'] |=
  ["--add-module=#{::File.join(node['mod_security2']['home'], 'current', 'nginx', 'modsecurity')}"]

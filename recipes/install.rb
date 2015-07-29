mod_security2 node['mod_security2']['source']['revision'] do
  platform node['mod_security2']['platform']
  action :install
end

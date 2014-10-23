mod_security2 node['mod_security2']['home'] do
  action   :install
  platform node['mod_security2']['platform']
end

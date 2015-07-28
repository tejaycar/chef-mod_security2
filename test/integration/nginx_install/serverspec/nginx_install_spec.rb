require 'spec_helper'

describe command("#{::File.join('', 'opt', 'nginx-1.4.4', 'sbin', 'nginx')} -V") do
  its(:stderr) { should match %r{/opt/ModSecurity/current/nginx/modsecurity} }
end

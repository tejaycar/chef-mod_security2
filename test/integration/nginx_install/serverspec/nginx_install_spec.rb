require 'spec_helper'

describe command("#{::File.join('', 'opt', 'nginx-1.6.2', 'sbin', 'nginx')} -V") do
  its(:stderr) { should match %r{/opt/ModSecurity/current/nginx/modsecurity} }
end

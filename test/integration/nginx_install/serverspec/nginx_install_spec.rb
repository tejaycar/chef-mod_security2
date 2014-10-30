require 'spec_helper'

describe file('/opt/ModSecurity') do
  it { should be_directory }
end

describe file('/opt/ModSecurity/current') do
  it { should be_linked_to '/opt/ModSecurity/versions/v2.8.0' }
end

describe file('/opt/ModSecurity/current/nginx/modsecurity/ngx_http_modsecurity.c') do
  it { should be_file }
  it { should be_readable }
end

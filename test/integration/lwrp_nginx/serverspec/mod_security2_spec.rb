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

## for ubuntu (not sure I care.  This is a pre-req, but not an issue for final release
%w(libxml2
   libxml2-dev
   libxml2-utils
   libaprutil1
   libaprutil1-dev
   autoconf
   automake
   libtool
   apache2-threaded-dev
).each do |pak|
  describe package(pak) do
    it { should be_installed }
  end
end

require 'spec_helper'

describe file('/opt/ModSecurity') do
  it { should be_directory }
end

describe file('/opt/ModSecurity/current') do
  it { should be_linked_to '/opt/ModSecurity/v2.8.0/ModSecurity' }

describe file('/opt/ModSecurity/current/nginx/modsecurity') do
  it { should be_file }
  it { should be_readable }
end

## for ubuntu
%(libxml2 libxml2-dev libxml2-utils libaprutil1 libaprutil1-dev).each do |pak|
  describe package(pak) do
    it { should be_installed }
  end
end
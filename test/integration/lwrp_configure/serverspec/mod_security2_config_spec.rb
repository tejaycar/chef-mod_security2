require 'spec_helper'

describe file('/etc/ModSecurity') do
  it { should be_directory }
end

describe file('/etc/ModSecurity/modsecurity.conf') do
  it { should be_file }
  its(:content) { should match(/Core ModSecurity Rule Set/) }
  its(:content) { should match(/Rule engine initialization/) }
  its(:content) { should match(/modsecurity_crs_20_protocol_violations\.conf/) }
end

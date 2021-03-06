require 'spec_helper'

describe 'mod_security2::install' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(:step_into => 'mod_security2').converge(described_recipe)
  end

  it 'calls the lwrp' do
    expect(chef_run).to install_mod_security2('v2.9.0')
  end

  context 'installing mod_security' do
    %w(git
       libxml2
       libxml2-dev
       libxml2-utils
       libaprutil1
       libaprutil1-dev
       autoconf
       automake
       libtool
       apache2-threaded-dev
       libcurl4-openssl-dev
       libyajl-dev
       liblua5.1-0-dev
    ).each do |pak|
      it "installs #{pak}" do
        expect(chef_run).to install_package(pak)
      end
    end

    it 'creates the versions directory' do
      expect(chef_run).to create_directory('/opt/ModSecurity/versions').with(
        :recursive => true
      )
    end

    it 'creates a link from current to the version installed' do
      expect(chef_run).to create_link('/opt/ModSecurity/current').with(
        :to => '/opt/ModSecurity/versions/v2.9.0'
      )
    end

    it 'syncs the source code' do
      expect(chef_run).to checkout_git('/opt/ModSecurity/versions/v2.9.0').with(
        :repo => 'https://github.com/SpiderLabs/ModSecurity.git',
        :revision => 'v2.9.0'
      )
    end

    it 'exectues the build' do
      expect(chef_run).to run_execute('build mod_security')
    end
  end

  it 'can install standalone mod_security' do
    chef_run.node.set['mod_security2']['platform'] = :nginx
    chef_run.converge(described_recipe)

    expect(chef_run).to run_execute('build mod_security').with(
      :command => /standalone/
    )
  end
end

require 'spec_helper'

describe 'mod_security2::install' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  it 'installs mod_security' do
    expect(chef_run).to install_mod_security2('v2.9.0')
  end
end

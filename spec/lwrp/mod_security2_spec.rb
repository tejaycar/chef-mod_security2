require 'spec_helper'

describe 'mod_security2::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(:step_into => 'mod_security2').converge('mod_security2')
  end

  it 'installs mod_security'
  it 'can install standalone mod_security'
end

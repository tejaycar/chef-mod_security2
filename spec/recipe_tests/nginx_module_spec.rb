require 'spec_helper'

describe 'mod_security2::nginx_module' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  it 'sets the flags to add mod_security during nginx compile' do
    expect(chef_run.node.run_state['nginx_configure_flags'] &&
      chef_run.node.run_state['nginx_configure_flags'].include?(
        "--add-module=#{chef_run.node['mod_security2']['home']}/nginx/modsecurity"
      )
    )
  end
end

class Chef
  class Resource::ModSecurity2 < Resource
    include Poise

    actions [:install, :update, :remove]

    attribute :path, :kind_of => String, :name_attribute => true
    attribute :platform, :kind_of => [String, Symbol], :default => :nginx,
      :equal_to => [:nginx, 'nginx'] # , :apache, 'apache']
    attribute :compile_flags, :kind_of => String
  end

  class Provider::ModSecurity2 < Provider
    include Poise

    def action_install
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
      ).each do |pak|
        package pak
      end

      directory ::File.join(node['mod_security2']['home'], 'versions') do
        recursive true
        action    :create
      end

      version_path = ::File.join(node['mod_security2']['home'], 'versions',
                      node['mod_security2']['source']['revision'])

      git version_path do
        revision   node['mod_security2']['source']['revision']
        repository node['mod_security2']['source']['repo']
        action     :sync
      end

      link ::File.join(node['mod_security2']['home'], 'current') do
        to version_path
      end

      execute 'build mod-security' do
        compile_flags = node['mod_security2']['source']['compile_flags']
        compile_flags |= new_resource.compile_flags if new_resource.compile_flags

        if new_resource.platform == :nginx
          compile_flags |= %w(--enable-standalone-module)
        end

        cwd version_path
        command "./autogen.sh && ./configure #{compile_flags.join(' ')}"
        not_if { ::File.exist? ::File.join(version_path, 'libtool') }
      end
    end

    def action_update; end

    def action_remove; end
  end
end

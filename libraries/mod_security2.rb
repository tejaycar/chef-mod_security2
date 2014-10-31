class Chef
  class Resource::ModSecurity2 < Resource
    include Poise

    actions [:install, :delete]

    attribute :home, :kind_of => String
    attribute :platform, :kind_of => [String, Symbol], :equal_to => [:nginx, 'nginx'] # , :apache, 'apache']
    attribute :compile_flags, :kind_of => [Array, String], :default => []
    attribute :version, :kind_of => String, :name_attribute => true
    attribute :repo, :kind_of => String

    def initialize(name, run_context = nil)
      super(name, run_context)
      @home ||= node['mod_security2']['home']
      @platform ||= node['mod_security2']['platform']
      @version ||= node['mod_security2']['source']['revision']
      @repo ||= node['mod_security2']['source']['repo']
    end
  end

  class Provider::ModSecurity2 < Provider
    include Poise

    def action_install
      node['mod_security2']['source']['packages'].each do |pak|
        package pak
      end

      directory ::File.join(new_resource.home, 'versions') do
        recursive true
        action    :create
      end

      git version_path do
        revision   new_resource.version
        repository new_resource.repo
        action     :checkout
      end

      link ::File.join(new_resource.home, 'current') do
        to version_path
      end

      execute 'build mod_security' do
        compile_flags = new_resource.compile_flags
        compile_flags = [compile_flags] unless compile_flags.is_a? Array

        if new_resource.platform.to_sym.eql? :nginx
          compile_flags |= %w(--enable-standalone-module)
        end

        cwd version_path
        command "./autogen.sh && ./configure #{compile_flags.join(' ')} && make"
        not_if { ::File.exist? ::File.join(version_path, 'apache2', '.libs') }
      end
    end

    def action_delete
      directory version_path do
        action :delete
      end

      link ::File.join(new_resource.home, 'current') do
        to     version_path
        action :delete
      end
    end

    def version_path
      ::File.join(new_resource.home, 'versions', new_resource.version)
    end
  end
end

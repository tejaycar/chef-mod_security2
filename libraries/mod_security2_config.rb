class Chef
  class Resource::ModSecurity2Config < Resource
    include Poise

    actions [:create, :delete]
    default_action :create

    attribute :path, :kind_of => String, :name_attribute => true
    attribute :custom_rules, :kind_of => Hash, :default => {}
    attribute :base_rules, :kind_of => [Array, TrueClass, FalseClass], :default => true
    attribute :optional_rules, :kind_of => [Array, TrueClass, FalseClass], :default => false
    attribute :experimental_rules, :kind_of => [Array, TrueClass, FalseClass], :default => false
    attribute :slr_rules, :kind_of => [Array, TrueClass, FalseClass], :default => false
    attribute :tarball_url, :kind_of => String,
                            :default => 'https://github.com/SpiderLabs/owasp-modsecurity-crs/tarball/master'

    def initialize(name, run_context = nil)
      super(name, run_context)
      @home ||= node['mod_security2']['home']
      @provider = Provider::ModSecurity2NginxConfig
      @temp_dir = ::File.join(Chef::Config[:file_cache_path], 'mod_security_temp')
    end

    attr_reader :temp_dir
    attr_reader :home
  end

  class Provider::ModSecurity2NginxConfig < Provider
    include Poise

    def action_create
      owasp_config = ::File.join(new_resource.temp_dir, 'SpiderLabs-owasp-modsecurity-crs-*',
                                 'modsecurity_crs_10_setup.conf.example')
      unless ::Dir.glob(owasp_config).length > 0
        directory new_resource.temp_dir do
          action :nothing
        end.run_action(:create)

        remote_file 'OWSASP rule set' do
          path ::File.join(new_resource.temp_dir, 'OWSASP.tgz')
          source new_resource.tarball_url
          action :nothing
        end.run_action(:create)

        execute 'unpack it' do
          action :nothing
          cwd new_resource.temp_dir
          command 'tar xzf OWSASP.tgz'
          action :nothing
        end.run_action(:run)
      end

      recommended_config = ::File.join(new_resource.home, 'current', 'modsecurity.conf-recommended')
      unless ::File.exist? recommended_config
        fail "#{recommended_config} missing please install mod_security by utilizing the mod_security2 resource to get this config"
      end
      contents = [['#####', '#', '# modsecurity.conf-recommended', '#', "######\n"].join("\n")]
      contents += IO.readlines recommended_config

      files = ::Dir.glob(owasp_config)
      owasp_config = ::File.dirname(files[0]) # get just the dirname for the config
      files += build_custom_rules
      files += add_paths(owasp_config, 'base_rules', new_resource.base_rules)
      files += add_paths(owasp_config, 'optional_rules', new_resource.optional_rules)
      files += add_paths(owasp_config, 'experimental_rules', new_resource.experimental_rules)
      files += add_paths(owasp_config, 'slr_rules', new_resource.slr_rules)

      files.sort_by! { |path| ::File.basename(path) }
      data_files = files.select { |f| !f.match(/\.conf(\.example)?$/) }
      data_files << ::File.join(new_resource.home, 'current', 'unicode.mapping')
      files -= data_files
      contents = files.reduce(contents) do |a, e|
        a << ['#####', '#', "\# #{::File.basename(e)}", '#', "######\n"].join("\n")
        a + IO.readlines(e)
      end

      notifying_block do
        file new_resource.path do
          content contents.join('')
        end

        data_files.each do |filename|
          file ::File.basename(filename) do
            path ::File.join(::File.dirname(new_resource.path), ::File.basename(filename))
            content IO.read(filename)
          end
        end
      end
    end

    def action_delete
      notifying_block do
        file new_resource.path do
          action :delete
        end
      end
    end

    def add_paths(base, path, enabled)
      return [] unless enabled

      if enabled.is_a? Array
        enabled.map { |config| ::File.join(new_resource.home, path, config) }
      else
        entries = ::Dir.glob(::File.join(base, path, '*'))
        entries.select { |p| ::File.file?(p) }
      end
    end

    def build_custom_rules
      rules_files = []
      new_resource.custom_rules.each do |key, value|
        build_rule(rules_files, key, value)
      end
      rules_files
    end

    def build_rule(rules_files, key, value)
      if value.is_a? String
        rules_files << value
      elsif value.is_a? Hash
        if value[:type] == :template
          fail('custom rule templates must have a :cookbook and :source') unless value[:source] && value[:cookbook]
          rules_files << build_template(key, value[:cookbook], value[:source], value[:priority] || 50)
        elsif value[:type] == :cookbook_file
          fail('custom rule cookbook_files must have a :cookbook and :source') unless value[:source] && value[:cookbook]
          rules_files << build_cookbook_file(key, value[:cookbook], value[:source], value[:priority] || 50)
        elsif value[:type] == :remote_file
          fail('custom rule remote_files must have a :url') unless value[:url]
          rules_files << build_remote_file(key, value[:url], value[:priority] || 50)
        else
          fail 'Custom rules which have non-string values must have a value[:type] of :cookbook_file, :template, or :remote_file'
        end
      else
        fail 'Custom rules must have a value of either Hash, or String (the full path to the rules file)'
      end
    end

    def build_template(name, cookbook, source, priority)
      file_path = ::File.join(new_resource.temp_dir, "modsecurity_crs_#{priority}_#{name}.conf")
      template "mod_security-#{name}" do
        path file_path
        cookbook cookbook
        source source
        action :nothing
      end.run_action(:create)
      file_path
    end

    def build_cookbook_file(name, cookbook, source, priority)
      file_path = ::File.join(new_resource.temp_dir, "modsecurity_crs_#{priority}_#{name}.conf")
      cookbook_file "mod_security-#{name}" do
        path file_path
        cookbook cookbook
        source source
        action :nothing
      end.run_action(:create)
      file_path
    end

    def build_remote_file(name, url, priority)
      file_path = ::File.join(new_resource.temp_dir, "modsecurity_crs_#{priority}_#{name}.conf")
      remote_file "mod_security-#{name}" do
        path file_path
        source url
        action :nothing
      end.run_action(:create)
      file_path
    end
  end
end

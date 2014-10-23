if defined?(ChefSpec)
  ChefSpec.define_matcher :mod_security2

  def install_mod_security2(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mod_security2, :install, resource_name)
  end

  def update_mod_security2(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mod_security2, :update, resource_name)
  end

  def remove_mod_security2(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mod_security2, :remove, resource_name)
  end
end
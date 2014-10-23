class Chef
  class Resource::ModSecurity2 < Resource
    include Poise

    actions [:install, :update, :remove]

    attribute :path, :kind_of => String, :name_attribute => true
    attribute :platform, :kind_of => [String, Symbol], :default => :nginx
  end

  class Provider::ModSecurity2 < Provider
    include Poise

    def action_install; end
    def action_update; end
    def action_remove; end
  end
end
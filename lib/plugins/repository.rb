module Plugins
  class Repository

    def self.store(plugin)
      repository[plugin.name] = plugin
    end

    def self.install_plugins!
      Dir.chdir('plugins') { Dir['*/plugin.rb'].each { |file| load file } }
      repository.values.each do |plugin|
        next unless plugin.enabled

        plugin.actions.map(&:call)
        plugin.assets.map         { |asset|  save_asset(asset) }
        plugin.static_assets.map  { |asset|  save_static_asset(asset) }
        plugin.outlets.map        { |outlet| active_outlets[outlet.outlet_name] = active_outlets[outlet.outlet_name] << outlet }
        plugin.routes.map         { |route|  save_route(route) }
        plugin.events.map         { |events| events.call(EventBus) }
        plugin.proposal_kinds.map { |kind|   save_proposal_kind(kind) }
        plugin.installed = true
      end
      save_plugin_yaml
    end

    def self.translations_for(locale = I18n.locale)
      active_plugins.map(&:translations).reduce({}, :deep_merge).slice(locale.to_s)[locale.to_s] || {}
    end

    def self.to_config
      @@config ||= {
        installed:      active_plugins,
        outlets:        active_outlets,
        routes:         active_routes,
        proposal_kinds: active_proposal_kinds
      }
    end

    def self.static_assets
      @@static_assets ||= begin
        assets = Array(active_plugins.map(&:static_assets).reduce(&:merge)).reject(&:standalone).map(&:filename)
        {
          css: assets.select { |filename| ['scss', 'css'].include?  filename.split('.').last },
          js:  assets.select { |filename| ['js', 'coffee'].include? filename.split('.').last }
        }
      end
    end

    def self.save_asset(asset)
      ext = asset.split('.').last
      plugin_yaml[ext] = Array(plugin_yaml[ext]) | Array(asset)
    end
    private_class_method :save_asset

    def self.save_static_asset(asset)
      assets = Rails.application.config.assets
      path   = Rails.root.join('plugins', asset.path).to_s
      assets.precompile << asset.filename if asset.standalone && !assets.precompile.include?(asset.filename)
      assets.paths      << path           unless assets.paths.include?(path)
    end
    private_class_method :save_static_asset

    def self.save_route(route)
      Loomio::Application.routes.prepend { get route[:path] => 'application#boot_angular_ui' }
      active_routes.push route
    end
    private_class_method :save_route

    def self.save_proposal_kind(kind)
      active_proposal_kinds.push(kind)
    end
    private_class_method :save_proposal_kind

    def self.active_plugins
      repository.values.select(&:installed)
    end
    private_class_method :active_plugins

    def self.plugin_yaml
      @@plugin_yaml ||= { 'path' => '../plugins' }
    end
    private_class_method :plugin_yaml

    def self.save_plugin_yaml
      File.open([Rails.root, :angular, :tasks, :config, 'plugins.yml'].join('/'), 'w') { |f| f.write plugin_yaml.to_yaml }
    end
    private_class_method :save_plugin_yaml

    def self.active_outlets
      @@active_outlets ||= Hash.new { [] }
    end
    private_class_method :active_outlets

    def self.active_routes
      @@active_routes ||= []
    end
    private_class_method :active_routes

    def self.active_proposal_kinds
      @@active_proposal_kinds ||= []
    end
    private_class_method :active_proposal_kinds

    def self.repository
      @@repository ||= Hash.new
    end
    private_class_method :repository

  end
end

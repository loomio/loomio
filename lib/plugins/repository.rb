module Plugins
  class Repository

    def self.store(plugin)
      repository[plugin.name] = plugin
    end

    def self.install_plugins!(plugin_set = '*')
      ::Module.prepend Plugins::ModuleConstMissing
      return unless Dir.exists?('plugins')
      Dir["plugins/#{plugin_set}/*/plugin.rb"].each do |file|
        Dir.chdir(File.dirname(file)) { load File.basename(file) }
      end

      repository.values.each do |plugin|
        next unless plugin.enabled

        plugin.actions.map(&:call)
        plugin.assets.map        { |asset|  save_asset(asset) }
        plugin.static_assets.map { |asset|  save_static_asset(asset) }
        plugin.routes.map        { |route|  save_route(route) }
        plugin.events.map        { |events| events.call(EventBus) }
        plugin.extensions.map    { |ext|    ext.proc.call(ext.const); reload_callbacks[ext.const.to_s.to_sym].add(ext.proc) }
        plugin.extensions.clear
        plugin.installed = true
      end
    end

    def self.translations_for(locale = I18n.locale)
      active_plugins.map(&:translations).reduce({}, :deep_merge).slice(locale.to_s)[locale.to_s] || {}
    end

    def self.to_config
      {
        installed:    ActiveModel::ArraySerializer.new(active_plugins, each_serializer: PluginSerializer, root: false).as_json,
        outlets:      active_outlets,
        routes:       active_routes
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
      assets.precompile << asset.filename if asset.standalone && !assets.precompile.include?(asset.filename)
      assets.paths      << asset.path     unless assets.paths.include?(asset.path)
    end
    private_class_method :save_static_asset

    def self.save_route(route)
      Loomio::Application.routes.prepend { get route[:path] => 'application#index' }
      active_routes.push route
    end
    private_class_method :save_route

    def self.active_plugins
      repository.values.select(&:installed)
    end
    private_class_method :active_plugins

    def self.plugin_yaml
      @@plugin_yaml ||= { 'path' => '..' }
    end
    private_class_method :plugin_yaml

    def self.reload_callbacks
      @@reload_callbacks ||= Hash.new { |hash, key| hash[key] = Set.new }
    end

    def self.active_outlets
      @@active_outlets ||= Hash.new { [] }
    end
    private_class_method :active_outlets

    def self.active_routes
      @@active_routes ||= []
    end
    private_class_method :active_routes

    def self.repository
      @@repository ||= Hash.new
    end
    private_class_method :repository
  end
end

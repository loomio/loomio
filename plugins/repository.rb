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
        plugin.assets.map  { |asset|  save_asset(asset) }
        plugin.outlets.map { |outlet| active_outlets[outlet.outlet_name] = active_outlets[outlet.outlet_name] << outlet }
        plugin.events.map  { |events| events.call(EventBus) }
        plugin.installed = true
      end
      save_plugin_yaml
    end

    def self.translations_for(locale = I18n.locale)
      active_plugins.map(&:translations).reduce({}, :deep_merge).slice(locale.to_s)
    end

    def self.to_config
      {
        installed:    active_plugins,
        outlets:      active_outlets
      }
    end

    def self.save_asset(asset)
      ext = asset.split('.').last
      plugin_yaml[ext] = Array(plugin_yaml[ext]) | Array(asset)
    end
    private_class_method :save_asset

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

    def self.repository
      @@repository ||= Hash.new
    end
    private_class_method :repository

  end
end

module Plugins
  class NoCodeSpecifiedError < Exception; end
  class NoClassSpecifiedError < Exception; end
  class InvalidAssetType < Exception; end
  Outlet = Struct.new(:plugin, :component, :outlet_name, :experimental, :plans)
  StaticAsset = Struct.new(:path, :filename, :standalone)
  Extension = Struct.new(:const, :proc)
  VALID_ASSET_TYPES = [:coffee, :scss, :haml, :js, :css]

  class Base
    attr_accessor :name, :installed, :enabled # GK: TODO: enabled is to prevent existing plugins from blowing up, but we should fix all the plugins
    attr_reader :assets, :static_assets, :actions, :events, :outlets, :routes, :translations, :extensions, :enabled, :config
    alias :read_attribute_for_serialization :send

    def self.setup!(name)
      Repository.store new(name).tap { |plugin| yield plugin }
    end

    def initialize(name)
      @root = Dir.pwd
      @name = name
      @translations = {}
      @assets, @static_assets, @actions, @events, @outlets, @routes, @extensions = Set.new, Set.new, Set.new, Set.new, Set.new, Set.new, Set.new
      @config = File.exists?(config_file_path) ? YAML.load(ERB.new(File.read(config_file_path)).result) : {}
    end

    def enabled
      !disabled_plugins.include? self.name
    end

    def disabled_plugins
      ENV['DISABLED_PLUGINS'].to_s.split(" ").map(&:to_sym)
    end

    def use_class_directory(glob)
      use_directory(glob) { |path| use_class(path) }
    end

    def use_class(path = nil, &block)
      raise NoCodeSpecifiedError.new unless block_given? || path
      proc = block_given? ? block.to_proc : Proc.new { require path_prefix path }
      @actions.add proc
    end

    def use_database_table(table_name, &block)
      raise NoCodeSpecifiedError.new unless block_given?
      return if ActiveRecord::Base.connection.table_exists?(table_name)
      puts "Adding #{table_name} for plugin #{name}..."

      migration = ActiveRecord::Migration.new
      def migration.up(table_name, &block)
        create_table table_name.to_s.pluralize, &block
      end
      migration.up(table_name, &block)
    end

    def extend_class(const, &block)
      raise NoCodeSpecifiedError.new unless block_given?
      raise NoClassSpecifiedError.new unless const.present?
      @extensions.add Extension.new(const, Proc.new { |c| c.class_eval(&block) })
    end

    def use_asset_directory(glob)
      use_directory(glob) { |path| use_asset(path) }
    end

    def use_static_asset(path, filename, standalone: false)
      @static_assets.add StaticAsset.new(path_prefix(path), filename, standalone)
    end

    def use_static_asset_directory(path, standalone: false)
      Dir.entries(path_prefix(path))
         .reject { |p| ['.', '..'].include?(p) }
         .each { |filename| use_static_asset(path, filename, standalone: standalone) }
    end

    def use_translations(path, filename = :client)
      raise NoCodeSpecifiedError.new unless path
      Rails.application.config.i18n.load_path += Dir[path_prefix "#{path}/#{filename}.*.yml"]
      Dir.chdir(path_prefix) { Dir.glob("#{path}/#{filename}.*.yml").each { |path| use_translation(path) } }
    end

    def use_events(&block)
      raise NoCodeSpecifiedError.new unless block_given?
      @events.add block.to_proc
    end

    def use_component(component, outlet: nil)
      [:coffee, :scss, :haml].each { |ext| use_asset("components/#{component}/#{component}.#{ext}") }
      Array(outlet).each { |o| @outlets.add Outlet.new(@name, component, o, @config['experimental'], @config['plans']) }
    end

    def use_client_route(path, component)
      use_component(component)
      @routes.add({ path: path, component: component.to_s.camelize(:lower) })
    end

    def use_test_route(path, &block)
      raise NoCodeSpecifiedError.new unless block_given?
      extend_class(Dev::NightwatchController) { define_method(path, &block) }
    end

    def use_route(verb, route, action)
      @actions.add Proc.new {
        Loomio::Application.routes.prepend do
          namespace(:api, path: 'api/v1', defaults: {format: :json}) { send(verb, { route => action }) }
        end
      }.to_proc
    end

    def use_factory(name, &block)
      return unless Rails.env.test?
      raise NoCodeSpecifiedError.new unless block_given?
      @actions.add Proc.new {
        FactoryBot.define { factory(name, &block) } unless FactoryBot.factories.registered?(name)
      }.to_proc
    end

    def use_view_path(path)
      @actions.add Proc.new {
        ApplicationController.append_view_path(path_prefix(path, rails_root: false))
        BaseMailer.append_view_path(path_prefix(path, rails_root: false))
      }.to_proc
    end

    def use_page(route, path, redirect: false)
      @actions.add Proc.new {
        # prepending rather than appending so we can override application root route
        Loomio::Application.routes.prepend do
          if redirect
            get route.to_s => redirect(path)
          else
            get route.to_s => path, constraints: NotGroupSubdomainConstraints
          end
        end
      }.to_proc
    end

    def use_post_route(route, path)
      @actions.add Proc.new {
        # prepending rather than appending so we can override application root route
        Loomio::Application.routes.prepend do
          post route.to_s => path, constraints: NotGroupSubdomainConstraints
        end
      }.to_proc
    end

    def use_root_page(path)
      @actions.add Proc.new {
        Loomio::Application.routes.append do
          root to: path, as: 'not_root'
        end
      }.to_proc
    end

    def use_asset(path)
      raise InvalidAssetType.new unless VALID_ASSET_TYPES.include? path.split('.').last.to_sym
      @assets.add path_prefix(path, rails_root: false)
    end

    def use_e2e(path)
      @actions.add Proc.new {
        system("cp #{path_prefix(path)} #{Rails.root}/client/angular/test/nightwatch/plugins/#{path.split('/').last}")
      }.to_proc
    end

    private

    def path_prefix(path = nil, rails_root: true)
      path = [@root, path].compact.join('/')
      path = path.sub("#{Rails.root}/", '') unless rails_root
      path
    end

    def config_file_path
      path_prefix 'config.yml'
    end

    def use_translation(path)
      @translations.deep_merge! YAML.load_file(path)
    end

    def use_directory(glob)
      Dir.chdir(path_prefix) { Dir.glob("#{glob}/*.*").each { |path| yield path } }
    end

  end
end

require "#{Rails.root}/lib/plugins/repository"

module Plugins
  class NoCodeSpecifiedError < Exception; end
  class NoClassSpecifiedError < Exception; end
  class InvalidAssetType < Exception; end
  Outlet = Struct.new(:plugin, :component, :outlet_name, :experimental, :plans, :proposal_kind)
  StaticAsset = Struct.new(:path, :filename, :standalone)
  VALID_ASSET_TYPES = [:coffee, :scss, :haml, :js, :css]

  class Base
    PLUGIN_FIELD_SETS = [:assets,
                         :static_assets,
                         :actions,
                         :events,
                         :outlets,
                         :routes,
                         :proposal_kinds]
   attr_accessor :name, :installed
   attr_reader *PLUGIN_FIELD_SETS
   attr_reader :enabled, :translations

    def self.setup!(name)
      Repository.store new(name).tap { |plugin| yield plugin }
    end

    def initialize(name)
      @name = name
      @translations = {}
      PLUGIN_FIELD_SETS.map { |field| instance_variable_set "@#{field}", Set.new }
      @config = File.exists?(config_file_path) ? YAML.load(ERB.new(File.read(config_file_path)).result) : {}
    end

    def enabled=(value)
      @enabled = value.is_a?(TrueClass) || ENV[value]
    end

    def use_class_directory(glob)
      use_directory(glob) { |path| use_class(path) }
    end

    def use_class(path = nil, &block)
      raise NoCodeSpecifiedError.new unless block_given? || path
      proc = block_given? ? block.to_proc : Proc.new { require [Rails.root, :plugins, @name, path].join('/') }
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

    def extend_class(klass, &block)
      raise NoCodeSpecifiedError.new unless block_given?
      raise NoClassSpecifiedError.new unless klass.present?
      klass.class_eval &block
    end

    def use_asset_directory(glob)
      use_directory(glob) { |path| use_asset(path) }
    end

    def use_static_asset(path, filename, standalone: false)
      @static_assets.add StaticAsset.new([@name, path].join('/'), filename, standalone)
    end

    def use_static_asset_directory(path, standalone: false)
      Dir.entries([@name.to_s, path].join('/'))
         .reject { |p| ['.', '..'].include?(p) }
         .each { |filename| use_static_asset(path, filename, standalone: standalone) }
    end

    def use_translations(path, filename = :client)
      raise NoCodeSpecifiedError.new unless path
      Dir.chdir(@name.to_s) { Dir.glob("#{path}/#{filename}.*.yml").each { |path| use_translation(path) } }
    end

    def use_events(&block)
      raise NoCodeSpecifiedError.new unless block_given?
      @events.add block.to_proc
    end

    def use_component(component, outlet: nil, proposal_kind: nil)
      [:coffee, :scss, :haml].each { |ext| use_asset("components/#{component}/#{component}.#{ext}") }
      Array(outlet).each { |o| @outlets.add Outlet.new(@name, component, o, @config['experimental'], @config['plans'], proposal_kind) }
    end

    def use_client_route(path, component)
      use_component(component)
      @routes.add({ path: path, component: component.to_s.camelize(:lower) })
    end

    def use_test_route(path, &block)
      raise NoCodeSpecifiedError.new unless block_given?
      extend_class(DevelopmentController) { define_method(path, &block) }
    end

    def use_view_path(path, controller: ApplicationController)
      raise NoCodeSpecifiedError.new unless path.present?
      @actions.add Proc.new { controller.prepend_view_path [:plugins, @name, path].join('/') }
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
        FactoryGirl.define { factory(name, &block) } unless FactoryGirl.factories.registered?(name)
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

    def use_root_page(path)
      @actions.add Proc.new {
        Loomio::Application.routes.append do
          root to: path, as: 'not_root'
        end
      }.to_proc
    end

    def use_asset(path)
      raise InvalidAssetType.new unless VALID_ASSET_TYPES.include? path.split('.').last.to_sym
      @assets.add [@name, path].join('/')
    end

    def register_proposal_kind(kind, vote:, proposal:, vote_form:, proposal_form: nil, preview_large: nil, preview_small: nil)
      @proposal_kinds.add(kind)
      use_component vote,          outlet: :vote_display,           proposal_kind: kind
      use_component proposal,      outlet: :proposal_display,       proposal_kind: kind
      use_component vote_form,     outlet: :vote_form,              proposal_kind: kind
      use_component proposal_form, outlet: :proposal_form,          proposal_kind: kind if proposal_form
      use_component preview_large, outlet: :proposal_preview_large, proposal_kind: kind if preview_large
      use_component preview_small, outlet: :proposal_preview_small, proposal_kind: kind if preview_small
    end

    private

    def config_file_path
      [@name, 'config.yml'].join('/')
    end

    def use_translation(path)
      @translations.deep_merge! YAML.load_file(path)
    end

    def use_directory(glob)
      Dir.chdir(@name.to_s) { Dir.glob("#{glob}/*").each { |path| yield path } }
    end

  end
end

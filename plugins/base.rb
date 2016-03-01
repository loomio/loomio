require "#{Rails.root}/plugins/repository"

module Plugins
  class NoCodeSpecifiedError < Exception; end
  class NoClassSpecifiedError < Exception; end
  class InvalidAssetType < Exception; end
  Outlet = Struct.new(:plugin, :component, :outlet_name)
  VALID_ASSET_TYPES = [:coffee, :scss, :haml, :js, :css]

  class Base
    attr_accessor :name, :installed
    attr_reader :assets, :actions, :events, :outlets, :translations, :enabled

    def self.setup!(name)
      Repository.store new(name).tap { |plugin| yield plugin }
    end

    def initialize(name)
      @name = name
      @translations = {}
      @assets, @actions, @events, @outlets = Set.new, Set.new, Set.new, Set.new
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
        create_table table_name, &block
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

    def use_translations(path, filename = :client)
      raise NoCodeSpecifiedError.new unless path
      Dir.chdir(@name.to_s) { Dir.glob("#{path}/#{filename}.*.yml").each { |path| use_translation(path) } }
    end

    def use_events(&block)
      raise NoCodeSpecifiedError.new unless block_given?
      @events.add block.to_proc
    end

    def use_component(component, outlet: nil)
      [:coffee, :scss, :haml].each { |ext| use_asset("components/#{component}/#{component}.#{ext}") }
      @outlets.add Outlet.new(@name, component, outlet) if outlet
    end

    def use_route(verb, route, action)
      @actions.add Proc.new {
        Loomio::Application.routes.append do
          namespace(:api, path: 'api/v1', defaults: {format: :json}) { send(verb, { route => action }) }
        end
      }.to_proc
    end

    def use_asset(path)
      raise InvalidAssetType.new unless VALID_ASSET_TYPES.include? path.split('.').last.to_sym
      @assets.add [@name, path].join('/')
    end

    private

    def use_translation(path)
      @translations.deep_merge! YAML.load_file(path)
    end

    def use_directory(glob)
      Dir.chdir(@name.to_s) { Dir.glob("#{glob}/*").each { |path| yield path } }
    end

  end
end

module IsTranslatable
  module Model
    
    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods
      def is_translatable(on: [], load_via: :find, id_field: :id, language_field: :language)
        return unless TranslationService.available?
        
        define_singleton_method :translatable_fields, -> { Array on }
        define_singleton_method :get_instance, ->(id) { send load_via, id }
        
        define_method :id_field, -> { send id_field }
        define_method :language_field, -> { send language_field }
        
        send :include, Translatable
      end
    end

  end
end

ActiveSupport.on_load(:active_record) do
  include IsTranslatable::Model
end
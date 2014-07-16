module IsTranslatable
  module Model

    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods
      def is_translatable(on: [], load_via: :find, id_field: :id, locale_field: :locale)
        return unless TranslationService.available?

        define_singleton_method :translatable_fields, -> { Array on }
        define_singleton_method :get_instance, ->(id) { send load_via, id }

        define_method :id_field, -> { send id_field }
        define_method :locale_field, -> { send locale_field }

        send :include, Translatable
      end
    end

  end
end

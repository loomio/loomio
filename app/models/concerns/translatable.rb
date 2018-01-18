module Translatable
  extend ActiveSupport::Concern

  included do
    has_many :translations, as: :translatable
    before_update :clear_translations, if: :translatable_fields_modified?
  end

  def translatable_fields_modified?
    return unless TranslationService.supported_languages.any?
    (self.saved_changes.keys.map(&:to_sym) & self.class.translatable_fields).any?
  end

  def clear_translations
    self.translations.delete_all
  end

  module ClassMethods
    def is_translatable(on: [], load_via: :find, id_field: :id, locale_field: :locale)

      define_singleton_method :translatable_fields, -> { Array on }
      define_singleton_method :get_instance, ->(id) { send load_via, id }

      define_method :id_field, -> { send id_field }
      define_method :locale_field, -> { send locale_field }
    end
  end
end

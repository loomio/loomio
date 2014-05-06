module Translatable
  # Requires base class to define:
  # => language
  extend ActiveSupport::Concern

  included do
    has_many :translations, as: :translatable
    before_update :clear_translations, if: :translatable_fields_modified?
  end

  protected
  
  def translatable_fields_modified?
    (self.changed.map(&:to_sym) & self.class.translatable_fields).any?
  end

  def clear_translations
    self.translations.delete_all
  end

end

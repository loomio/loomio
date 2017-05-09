class Translation < ActiveRecord::Base
  belongs_to :translatable, polymorphic: true
  scope :to_language, ->(language) { where(language: language) }

  validates_presence_of :translatable, :language
  validates_inclusion_of :language, in: TranslationService.supported_languages

  # TODO: Should probably move to a serializer
  def as_json
    { id: translatable_id }.merge(fields)
  end
end

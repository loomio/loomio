class Translation < ActiveRecord::Base
  belongs_to :translatable, polymorphic: true
  scope :to_language, ->(language) { where(language: language) }

  validates_presence_of :translatable, :language
  def as_json
    { id: translatable_id }.merge(fields)
  end
end

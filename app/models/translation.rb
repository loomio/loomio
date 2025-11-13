class Translation < ApplicationRecord
  belongs_to :translatable, polymorphic: true
  validates_presence_of :translatable, :language
end

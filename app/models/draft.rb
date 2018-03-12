class Draft < ApplicationRecord
  belongs_to :user
  belongs_to :draftable, polymorphic: true

  validates :user, presence: true
  validates :draftable, presence: true

  DRAFTABLE_MODELS = ['user', 'group', 'discussion', 'poll']
end

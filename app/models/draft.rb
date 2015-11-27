class Draft < ActiveRecord::Base
  belongs_to :user
  belongs_to :draftable, polymorphic: true

  validates :user, presence: true
  validates :draftable, presence: true

  def self.purge(user:, draftable:, field:)
    find_or_initialize_by(user: user, draftable: draftable).purge(field)
  end

  def purge(field)
    self.payload[field] = {}
    self.tap(&:save)
  end
end

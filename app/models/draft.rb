class Draft < ActiveRecord::Base
  belongs_to :user
  belongs_to :draftable, polymorphic: true

  validates :user, presence: true
  validates :draftable, presence: true

  DRAFTABLE_MODELS = ['user', 'group', 'discussion', 'motion', 'poll']

  class << self
    def purge(user:, draftable:, field:)
      find_or_initialize_by(user: user, draftable: draftable).purge(field)
    end
    handle_asynchronously :purge
  end

  def purge(field)
    self.payload[field] = {}
    self.tap(&:save)
  end
end

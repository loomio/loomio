class Draft < ActiveRecord::Base
  belongs_to :user
  belongs_to :draftable, polymorphic: true

  validates :user, presence: true
  validates :draftable, presence: true

  class << self
    def purge(user:, draftable:, field:)
      find_or_initialize_by(user: user, draftable: draftable).purge(field)
    end
    handle_asynchronously :purge
  end
  EventBus.listen('comment_create') { |comment| purge_without_delay(user: comment.user, draftable: comment.discussion, field: :comment) }

  def purge(field)
    self.payload[field] = {}
    self.tap(&:save)
  end
end

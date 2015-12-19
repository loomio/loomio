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
  EventBus.listen('comment_create')    { |comment|    purge_without_delay(user: comment.user, draftable: comment.discussion, field: :comment) }
  EventBus.listen('motion_create')     { |motion|     purge(user: motion.author, draftable: motion.discussion, field: :motion) }
  EventBus.listen('discussion_create') { |discussion| purge(user: discussion.author, draftable: discussion.group, field: :discussion) }

  def purge(field)
    self.payload[field] = {}
    self.tap(&:save)
  end
end

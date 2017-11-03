class Reaction < ActiveRecord::Base
  belongs_to :reactable, polymorphic: true
  belongs_to :user

  # TODO: ensure one reaction per reactable
  # validates_uniqueness_of :user_id, scope: :reactable
  validates_presence_of :user, :reactable

  delegate :group, to: :reactable, allow_nil: true
  delegate :groups, to: :reactable, allow_nil: true

  alias :author :user

  def author_id
    user_id
  end

  def message_channel
    case reactable
    when Outcome, Stance, Poll then reactable.poll.message_channel
    when Comment, Discussion   then reactable.discussion.message_channel
    end
  end
end

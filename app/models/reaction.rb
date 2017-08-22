class Reaction < ActiveRecord::Base
  belongs_to :reactable, polymorphic: true
  belongs_to :user

  validates_uniqueness_of :user_id, scope: [:reactable_id, :reactable_type]
  validates_presence_of :user, :reactable

  alias :author :user

  def message_channel
    case reactable
    when Outcome, Stance, Poll then reactable.poll.message_channel
    when Comment, Discussion   then reactable.discussion.message_channel
    end
  end
end

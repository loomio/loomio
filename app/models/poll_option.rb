class PollOption < ActiveRecord::Base
  belongs_to :poll
  validates :name, presence: true

  has_many :stance_choices
  has_many :stances, through: :stance_choices, dependent: :destroy

  def color
    Poll::COLORS.dig(poll.poll_type, self.priority)
  end
end

class PollOption < ActiveRecord::Base
  belongs_to :poll
  validates :name, presence: true

  has_many :stance_choices, dependent: :destroy
  has_many :stances, through: :stance_choices

  def color
    Poll::COLORS.dig(poll.poll_type, self.priority)
  end
end

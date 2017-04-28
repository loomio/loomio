class PollOption < ActiveRecord::Base
  belongs_to :poll
  validates :name, presence: true

  has_many :stance_choices, dependent: :destroy
  has_many :stances, through: :stance_choices

  def color
    Poll::COLORS.dig(poll.poll_type, self.priority)
  end

  def display_name
    if poll.dates_as_options
      DateTime.strptime(self.name.sub('.000Z', 'Z')).strftime('%-d %b - %l:%M%P')
    else
      name.humanize
    end
  end
end

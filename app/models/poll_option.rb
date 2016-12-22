class PollOption < ActiveRecord::Base
  belongs_to :poll
  validates :name, presence: true

  def self.for(poll_type)
    Poll::TEMPLATES.dig(poll_type, 'poll_options_attributes').map { |attrs| new(attrs) }
  end
end

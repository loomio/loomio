class FeedbackResponse < ActiveRecord::Base
  belongs_to :user
  belongs_to :visit

  validates :user, presence: true
  validates :feedback, presence: true

  delegate :name, to: :user, prefix: true
  delegate :email, to: :user, prefix: true
  delegate :user_agent, to: :visit, prefix: false, allow_nil: true

  scope :unprocessed, ->{ where processed: false }
  scope :processed, ->{ where processed: true }
end

class FeedbackResponse < ActiveRecord::Base
  belongs_to :user
  belongs_to :visit

  validates :user, presence: true
  validates :feedback, presence: true
end

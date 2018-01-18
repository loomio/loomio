class PollDidNotVote < ApplicationRecord
  belongs_to :poll, required: true
  belongs_to :user, required: true
end

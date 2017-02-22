class PollDidNotVote < ActiveRecord::Base
  belongs_to :poll, required: true
  belongs_to :user, required: true
end

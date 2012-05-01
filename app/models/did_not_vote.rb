class DidNotVote < ActiveRecord::Base
  belongs_to :user
  belongs_to :motion
end

class StanceChoice < ActiveRecord::Base
  belongs_to :poll_option
  belongs_to :stance
end

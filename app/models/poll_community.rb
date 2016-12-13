class PollCommunity < ActiveRecord::Base
  belongs_to :poll, required: true
  belongs_to :community, required: true, class_name: 'Communities::Base'
end

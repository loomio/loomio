class PollCommunity < ActiveRecord::Base
  belongs_to :poll, required: true
  belongs_to :community, class_name: 'Communities::Base'

  scope :for, ->(type) { joins(:community).where('communities.community_type': type) }
end

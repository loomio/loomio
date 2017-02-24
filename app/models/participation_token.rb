class ParticipationToken < ActiveRecord::Base
  belongs_to :poll, required: true
end

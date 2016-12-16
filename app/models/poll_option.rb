class PollOption < ActiveRecord::Base
  belongs_to :poll_template, required: false
end

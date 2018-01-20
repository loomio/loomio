class PollPollOption < ApplicationRecord
  belongs_to :poll, required: true
  belongs_to :poll_option, required: true
end

class PollOption < ActiveRecord::Base
  belongs_to :poll_template, required: false

  has_many :stances
end

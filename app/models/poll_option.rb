class PollOption < ActiveRecord::Base
  belongs_to :poll_template, required: false

  # we don't use these (and it doesn't really make sense to),
  # but they help fill out the picture of how poll options
  # relate to the rest of the architecture
  # has_many :poll_poll_options
  # has_many :polls, through: :poll_poll_options
  #
  # has_many :stances
  # has_many :participants, through: :stances
end

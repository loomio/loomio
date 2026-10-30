# Older polls and exported templates used "meeting" for availability. Normalize
# at the model boundary so they keep working without rewriting historical rows.
module AvailabilityPollType
  def poll_type
    self[:poll_type] == 'meeting' ? 'availability' : self[:poll_type]
  end

  def poll_type=(value)
    self[:poll_type] = value == 'meeting' ? 'availability' : value
  end
end

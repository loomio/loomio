module HasPollSequence
  extend ActiveSupport::Concern

  # Existing rows keep their legacy setting until the background conversion
  # reaches them. New rows use the database's false default immediately.
  def polls_one_at_a_time
    value = self[:polls_one_at_a_time]
    value.nil? ? !self[:allow_concurrent_polls] : value
  end
  alias_method :polls_one_at_a_time?, :polls_one_at_a_time

  # Keep the legacy column consistent for rollback during the transition.
  def polls_one_at_a_time=(value)
    value = ActiveModel::Type::Boolean.new.cast(value)
    self[:polls_one_at_a_time] = value
    self[:allow_concurrent_polls] = !value unless value.nil?
  end
end

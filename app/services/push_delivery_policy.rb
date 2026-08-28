class PushDeliveryPolicy
  def self.allowed?(user:, subject:)
    return false unless user&.active_for_authentication?

    model = if subject.is_a?(TopicItem)
      subject.topic
    elsif subject.respond_to?(:topic) && subject.topic
      subject.topic
    elsif subject.respond_to?(:group) && subject.group
      subject.group
    else
      subject
    end

    user.ability.can?(:show, model)
  rescue NoMethodError
    false
  end
end

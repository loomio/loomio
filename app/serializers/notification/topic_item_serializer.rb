class Notification::TopicItemSerializer < TopicItemSerializer
  def include_discussion?
    false
  end

  def include_parent?
    false
  end

  def include_reply_parent?
    false
  end
end

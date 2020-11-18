class Notification::EventSerializer < EventSerializer
  def include_discussion?
    false
  end

  def include_parent?
    false
  end
end

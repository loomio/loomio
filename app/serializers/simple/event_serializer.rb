class Simple::EventSerializer < EventSerializer
  def include_actor?
    false
  end

  def include_eventable?
    false
  end

  def include_discussion?
    false
  end

  def include_parent?
    false
  end

  def include_source_group?
    false
  end
end

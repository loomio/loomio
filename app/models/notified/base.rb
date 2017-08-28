class Notified::Base
  attr_reader :model
  alias :read_attribute_for_serialization :send

  def initialize(model)
    @model = model
  end

  def id
    model.id
  end

  def type
    model.class.to_s
  end

  def title
    nil
  end

  def subtitle
    nil
  end

  def icon_url
    nil
  end

  def notified_ids
    []
  end
end

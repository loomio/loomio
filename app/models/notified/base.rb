class Notified::Base
  attr_accessor :model
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

  def avatar_initials
    nil
  end

  def notified_ids
    []
  end

  def as_json
    NotifiedSerializer.new(self, root: false).as_json
  end
end

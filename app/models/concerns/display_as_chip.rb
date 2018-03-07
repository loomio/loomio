module DisplayAsChip
  extend ActiveSupport::Concern

  included do
    attr_accessor :model
    alias :read_attribute_for_serialization :send
  end

  def initialize(model)
    @model = model
  end

  def id
    model.id
  end

  def type
    self.class.to_s.demodulize
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
end

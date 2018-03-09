class Members::Base
  include DisplayAsChip

  def key
    "#{type.downcase}-#{model.id}"
  end

  def priority
    0
  end

  def last_notified_at
    nil
  end
end

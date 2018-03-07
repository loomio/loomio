class Notified::Base
  include DisplayAsChip

  def notified_ids
    []
  end

  def as_json
    NotifiedSerializer.new(self, root: false).as_json
  end
end

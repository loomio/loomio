# Vote weights change through update_all, which skips PaperTrail. Run the
# update inside record and it writes a version for each row whose weight changed.
# Stance weight versions use their own event so they stay out of the vote's
# revision history and edit count.
module WeightHistory
  def self.record(scope, actor_id:, event: "update")
    model = scope.model
    return yield unless PaperTrail.enabled? && PaperTrail.request.enabled_for_model?(model)

    before = scope.pluck(:id, :weight).to_h
    result = yield
    after = model.where(id: before.keys).pluck(:id, :weight).to_h
    now = Time.current
    rows = before.filter_map do |id, was|
      now_weight = after[id]
      next if was == now_weight
      {item_type: model.base_class.name, item_id: id, event: event, whodunnit: actor_id,
       created_at: now, object_changes: {"weight" => [was, now_weight]}}
    end
    PaperTrail::Version.insert_all(rows) if rows.any?
    result
  end
end

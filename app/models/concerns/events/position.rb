module Events::Position
  extend ActiveSupport::Concern

  included do
    after_destroy :reorder
    after_save :reorder, if: :parent_id_changed?
    belongs_to :parent, class_name: "Event", required: false
    has_many :children, class_name: "Event", foreign_key: :parent_id
    define_counter_cache(:child_count) { |e| e.children.count  }
    update_counter_cache :parent, :child_count
  end

  private
  def refresh_order_value
    self.position = self.class.select(:position).find(self.id).send(:position)
  end

  def reorder
    if parent_id
      reorder_with_parent_id(parent_id)
      refresh_order_value if self.persisted?
    end
  end

  def reorder_with_parent_id(parent_id)
    return if parent_id.nil? # we don't order outside of a parent
    ActiveRecord::Base.connection.execute <<-SQL.strip_heredoc
      UPDATE events
      SET position = t.seq + -1
      FROM (
        SELECT id AS id, row_number() OVER(ORDER BY id) AS seq
        FROM events
        WHERE parent_id = #{parent_id}
      ) AS t
      WHERE events.id = t.id and
            events.position is distinct from t.seq + -1
    SQL
  end
end

module Events::Position
  extend ActiveSupport::Concern

  included do
    before_save :set_depth
    before_create :set_position, if: :discussion_id
    after_destroy :reorder
    after_save :reorder, if: :parent_or_discussion_id_changed?
    belongs_to :parent, class_name: "Event", required: false
    has_many :children, (-> { where("discussion_id is not null") }), class_name: "Event", foreign_key: :parent_id
    define_counter_cache(:child_count) { |e| e.children.count  }
    update_counter_cache :parent, :child_count

    def self.reorder_with_parent_id(parent_id)
      ActiveRecord::Base.connection.execute <<-SQL.strip_heredoc
        UPDATE events
        SET position = t.seq
        FROM (
          SELECT id AS id, row_number() OVER(ORDER BY sequence_id) AS seq
          FROM events
          WHERE parent_id = #{parent_id}
          AND   discussion_id IS NOT NULL
        ) AS t
        WHERE events.id = t.id and
              events.position is distinct from t.seq
      SQL
    end
  end

  private
  def parent_or_discussion_id_changed?
    saved_change_to_attribute?(:parent_id) || saved_change_to_attribute?(:discussion_id)
  end

  def set_position
    self.position = self.class.where(discussion_id: self.discussion_id).maximum(:position).to_i + 1
  end

  def set_depth
    self.depth = parent ? (parent.depth + 1) : 0
  end

  def refresh_order_value
    self.position = self.class.select(:position).find(self.id).position
  end

  def reorder
    return unless parent_id
    self.class.reorder_with_parent_id(parent_id)
    refresh_order_value if self.persisted?
  end
end

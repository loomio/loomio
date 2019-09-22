module Events::Position
  extend ActiveSupport::Concern

  included do
    before_create :set_parent_and_depth
    after_save :reorder
    after_destroy :reorder

    belongs_to :parent, class_name: "Event", required: false
    has_many :children, (-> { where("discussion_id is not null") }), class_name: "Event", foreign_key: :parent_id
    define_counter_cache(:child_count) { |e| e.children.count  }
    update_counter_cache :parent, :child_count

    def self.reorder_with_parent_id(parent_id)
      ActiveRecord::Base.connection.execute(
        "UPDATE events SET position = t.seq
          FROM (
            SELECT id AS id, row_number() OVER(ORDER BY sequence_id) AS seq
            FROM events
            WHERE parent_id = #{parent_id}
            AND   discussion_id IS NOT NULL
          ) AS t
        WHERE events.id = t.id and
              events.position is distinct from t.seq")
    end
  end

  def set_parent_and_depth
    self.parent = find_parent_event
    self.depth = parent ? (parent.depth + 1) : 0
  end

  def set_parent_and_depth!
    set_parent_and_depth
    save!
  end

  def reload_position
    self.position = self.class.select(:position).find(self.id).position
  end

  def reorder
    return unless parent_id
    self.class.reorder_with_parent_id(parent_id)
    reload_position if self.persisted?
  end
end

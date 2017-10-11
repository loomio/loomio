module NumericOrderSupport
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
    self.position = self.class.select(order_column).find(self.id).send(order_column)
  end

  def reorder
    if parent_id
      reorder_with_parent_id(parent_id)
      refresh_order_value if self.persisted?
    end
  end

  def table_name
    "events"
  end

  def order_column
    "position"
  end

  def id_column_name
    "id"
  end

  def order_by
    "id"
  end

  def parent_column_name
    "parent_id"
  end

  def minimum_sort_order_value
    0
  end

  def reorder_with_parent_id(parent_id, minimum_sort_order_value = nil)
    return if parent_id.nil? # we don't order outside of a parent
    ActiveRecord::Base.connection.execute <<-SQL.strip_heredoc
      UPDATE #{table_name}
      SET #{order_column} = t.seq + #{minimum_sort_order_value.to_i - 1}
      FROM (
        SELECT #{id_column_name} AS id, row_number() OVER(ORDER BY #{order_by}) AS seq
        FROM #{table_name}
        WHERE parent_id = #{parent_id}
      ) AS t
      WHERE #{table_name}.#{id_column_name} = t.id and
            #{table_name}.#{order_column} is distinct from t.seq + #{minimum_sort_order_value.to_i - 1}
    SQL
  end
end

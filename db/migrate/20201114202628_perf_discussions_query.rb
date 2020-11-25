class PerfDiscussionsQuery < ActiveRecord::Migration[5.2]
  def change
    remove_index :discussions, name: :index_discussions_on_discarded_at
  end
end

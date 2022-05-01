class AddDiscardedAtIsNullIndex < ActiveRecord::Migration[6.1]
  def change
    add_index :discussions, :discarded_at, where: 'discarded_at IS NULL'
  end
end

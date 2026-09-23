class RemoveBlockedDomains < ActiveRecord::Migration[8.1]
  def change
    drop_table :blocked_domains do |t|
      t.string :name
      t.index :name, unique: true
    end
  end
end

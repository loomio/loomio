class AddBlockedDomains < ActiveRecord::Migration[6.1]
  def change
    create_table :blocked_domains do |t|
      t.string :name
    end
    add_index :blocked_domains, :name, unique: true
  end
end

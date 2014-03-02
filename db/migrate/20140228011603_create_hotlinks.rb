class CreateHotlinks < ActiveRecord::Migration
  def change
    create_table :hotlinks do |t|
      t.references :linkable, polymorphic: true
      t.string  :short_url
      t.integer :use_count, default: 0
      t.timestamps
    end
  end  
end

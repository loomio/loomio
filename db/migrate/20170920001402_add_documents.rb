class AddDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.references :model, polymorphic: true, null: false
      t.string :title
      t.string :url
      t.string :doctype, null: false
      t.string :color, null: false
      t.timestamps
    end
  end
end

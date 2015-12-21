class AddSoftDrafts < ActiveRecord::Migration
  def change
    create_table :drafts do |t|
      t.belongs_to :user
      t.belongs_to :draftable, polymorphic: true
      t.json :payload, default: {}, null: false
    end
  end
end

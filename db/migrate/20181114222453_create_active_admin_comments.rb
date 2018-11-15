class CreateActiveAdminComments < ActiveRecord::Migration[5.1]
  def self.up
    create_table :active_admin_comments do |t|
      t.string :namespace
      t.text   :body
      t.references :resource, polymorphic: true
      t.references :author, polymorphic: true
      t.timestamps
    end
  end

  def self.down
    drop_table :active_admin_comments
  end
end

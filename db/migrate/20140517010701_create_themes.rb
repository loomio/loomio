class CreateThemes < ActiveRecord::Migration
  def up
    create_table :themes do |t|
      t.text :style
      t.string :name

      t.timestamps
    end
    add_attachment :themes, :pages_logo
    add_attachment :themes, :app_logo
    add_column :groups, :subdomain, :string
    add_column :groups, :theme_id, :integer
  end

  def down
    drop_table :themes
    remove_column :groups, :subdomain
    remove_column :groups, :theme_id
  end
end

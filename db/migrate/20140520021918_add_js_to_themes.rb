class AddJsToThemes < ActiveRecord::Migration
  def change
    add_column :themes, :javascript, :text
  end
end

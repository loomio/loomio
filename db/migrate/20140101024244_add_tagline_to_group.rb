class AddTaglineToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :tagline, :string
  end
end

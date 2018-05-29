class AddTitleToMembership < ActiveRecord::Migration[5.1]
  def change
    add_column :memberships, :title, :string
  end
end

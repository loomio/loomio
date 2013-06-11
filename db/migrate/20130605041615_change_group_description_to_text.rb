class ChangeGroupDescriptionToText < ActiveRecord::Migration
  def up
    change_column :groups, :description, :text
  end

  def down
    #not required
  end
end

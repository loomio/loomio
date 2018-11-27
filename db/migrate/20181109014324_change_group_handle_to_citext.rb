class ChangeGroupHandleToCitext < ActiveRecord::Migration[5.1]
  def change
    change_column :groups, :handle, :citext
  end
end

class AddDemoHandleToTemplates < ActiveRecord::Migration[6.1]
  def change
    add_column :templates, :demo_handle, :string, default: nil
  end
end

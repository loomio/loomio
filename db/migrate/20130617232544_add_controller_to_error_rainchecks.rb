class AddControllerToErrorRainchecks < ActiveRecord::Migration
  def change
    add_column :error_rainchecks, :controller, :string
  end
end

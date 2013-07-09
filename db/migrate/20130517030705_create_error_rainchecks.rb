class CreateErrorRainchecks < ActiveRecord::Migration
  def change
    create_table :error_rainchecks do |t|
      t.string :email
      t.string :action

      t.timestamps
    end
  end
end

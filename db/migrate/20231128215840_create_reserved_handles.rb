class CreateReservedHandles < ActiveRecord::Migration[7.0]
  def change
    create_table :reserved_handles do |t|
      t.citext :handle, null: false
      t.string :email
    end
  end
end

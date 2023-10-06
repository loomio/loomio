class AddCreatedAndUpdatedAtToPollOption < ActiveRecord::Migration[6.1]
  def change
    add_column :poll_options, :created_at, :datetime, default: nil
    add_column :poll_options, :updated_at, :datetime, default: nil
  end
end

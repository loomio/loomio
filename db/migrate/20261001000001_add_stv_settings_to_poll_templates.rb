class AddStvSettingsToPollTemplates < ActiveRecord::Migration[8.1]
  # Defaults match a new poll's, so templates without STV settings still start
  # STV polls with one seat, Scottish STV and the Droop quota.
  def change
    add_column :poll_templates, :stv_seats, :integer, default: 1, null: false
    add_column :poll_templates, :stv_method, :string, default: "scottish", null: false
    add_column :poll_templates, :stv_quota, :string, default: "droop", null: false
  end
end

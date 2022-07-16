class AddRequireStanceReasonToPolls < ActiveRecord::Migration[6.1]
  def change
    add_column :polls, :stance_reason_required, :integer, null: false, default: 1
  end
end

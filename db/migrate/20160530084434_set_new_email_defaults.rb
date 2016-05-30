class SetNewEmailDefaults < ActiveRecord::Migration
  def change
    change_column :users, :email_on_participation, :boolean, default: false
    change_column :users, :default_membership_volume, :integer, default: 2
  end
end

class ConvertAccessLevelToBoolean < ActiveRecord::Migration
  def up
    add_column :memberships, :admin, :boolean, default: false, null: false

    Membership.reset_column_information
    Membership.find_each do |m|
      m.update_attribute(:admin, true) if m.access_level == 'admin'
    end

    remove_column :memberships, :access_level
  end

  def down
    add_column :memberships, :access_level, :string, default: 'member'

    Membership.reset_column_information
    Membership.find_each do |m|
      m.update_attribute(:access_level, 'admin') if m.admin?
    end

    remove_column :memberships, :admin
  end
end

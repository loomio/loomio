class ConvertAccessLevelToBoolean < ActiveRecord::Migration
  def up
    add_column :memberships, :admin, :boolean, default: false, null: false

    progress_bar = ProgressBar.create( format: "(\e[32m%c/%C\e[0m) %a |%B| \e[31m%e\e[0m ",
                                       progress_mark: "\e[32m/\e[0m",
                                       total: Membership.count )

    Membership.reset_column_information
    Membership.find_each do |m|
      progress_bar.increment
      m.update_attribute(:admin, true) if m.access_level == 'admin'
    end

    remove_column :memberships, :access_level
  end

  def down
    add_column :memberships, :access_level, :string, default: 'member'
    progress_bar = ProgressBar.create( format: "(\e[32m%c/%C\e[0m) %a |%B| \e[31m%e\e[0m ",
                                       progress_mark: "\e[32m/\e[0m",
                                       total: Membership.count )

    Membership.reset_column_information
    Membership.find_each do |m|
      progress_bar.increment
      m.update_attribute(:access_level, 'admin') if m.admin?
    end

    remove_column :memberships, :admin
  end
end

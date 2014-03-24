class FixPrivacy < ActiveRecord::Migration
  class Group < ActiveRecord::Base
  end

  def up
    add_column :groups, :visible, :boolean, default: true, null: false
    add_column :groups, :private_discussions_only, :boolean, default: true, null: false
    add_column :groups, :discussions_private_default, :boolean, default: nil, null: true
    rename_column :groups, :viewable_by_parent_members, :visible_to_parent_members
    add_index :groups, :visible

    Group.reset_column_information

    puts "Converting group.privacy setting"
    progress_bar = ProgressBar.create( format: "(\e[32m%c/%C\e[0m) %a |%B| \e[31m%e\e[0m ", progress_mark: "\e[32m/\e[0m", total: Group.count )

    Group.find_each do |group|
      case 
      when ['public', 'everyone'].include?(group.privacy)
        group.visible = true
        group.private_discussions_only = false
        group.discussions_private_default = false
      when ['private'].include?(group.privacy)
        group.visible = true
        group.private_discussions_only = false
        group.discussions_private_default = true
      when ['hidden', 'secret', 'members', 'parent_group_members'].include?(group.privacy)
        group.visible = false
        group.private_discussions_only = true
        group.discussions_private_default = true
      else
        puts "weird privacy group #{group.id} value #{group.privacy}"
      end
      group.save
      progress_bar.increment
    end

    change_column :groups, :private_discussions_only, :boolean, default: nil, null: false


  end

  def down
    remove_column :groups, :discussions_private_default
    remove_column :groups, :private_discussions_only
    remove_column :groups, :visible
    rename_column :groups, :visible_to_parent_members, :viewable_by_parent_members
  end
end

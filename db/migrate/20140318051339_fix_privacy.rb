class FixPrivacy < ActiveRecord::Migration
  class Group < ActiveRecord::Base
  end

  def up
    add_column :groups, :is_visible_to_public, :boolean, default: false, null: false
    add_column :groups, :is_visible_to_parent_members, :boolean, default: false, null: false
    add_column :groups, :discussion_privacy_options, :string, default: nil
    rename_column :groups, :viewable_by_parent_members, :parent_members_can_see_discussions
    add_column :groups,  :members_can_add_members, :boolean, default: false, null: false
    add_index :groups, :is_visible_to_public
    add_column :groups, :membership_granted_upon, :string, default: nil

    Group.reset_column_information

    puts "Converting group.privacy setting"

    Group.find_each do |group|
      group.parent_members_can_see_discussions = false
      case
      when ['public', 'everyone'].include?(group.privacy)
        group.is_visible_to_public = true
        group.discussion_privacy_options = 'public_or_private'
        group.membership_granted_upon = 'approval'
      when ['private'].include?(group.privacy)
        group.is_visible_to_public = true
        group.discussion_privacy_options = 'public_or_private'
        group.membership_granted_upon = 'approval'
      when ['hidden', 'secret', 'members'].include?(group.privacy)
        group.is_visible_to_public = false
        group.discussion_privacy_options = 'private_only'
        group.membership_granted_upon = 'invitation'
      when ['parent_group_members'].include?(group.privacy)
        group.is_visible_to_public = false
        group.is_visible_to_parent_members = true
        group.discussion_privacy_options= 'private_only'
        group.membership_granted_upon = 'invitation'
        group.parent_members_can_see_discussions = true
      else
        puts "weird privacy group #{group.id} value #{group.privacy}"
      end

      case group.members_invitable_by
      when 'members'
        group.members_can_add_members = true
      when 'admins'
        group.members_can_add_members = false
      end

      if group.parent_members_can_see_discussions?
        group.is_visible_to_parent_members = true
      end

      group.save
    end

    change_column :groups, :discussion_privacy_options, :string, default: nil, null: false
    change_column :groups, :membership_granted_upon, :string, default: nil, null: false


  end

  def down
    remove_column :groups, :members_can_add_members
    remove_column :groups, :private_discussions_only
    remove_column :groups, :visible
    rename_column :groups, :parent_members_can_see_discussions, :viewable_by_parent_members
    remove_column :groups, :parent_members_can_see_group
  end
end

class AddSubgroupMembersToParentGroup < ActiveRecord::Migration
  def up
    Membership.all.each do |membership|
      parent_group = membership.group_parent
      if parent_group.present?
        unless parent_group.users_include? membership.user
          parent_group.add_member!(membership.user)
        end
      end
    end
  end

  def down
  end
end

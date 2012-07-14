class AddCreatorIdToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :creator_id, :int
    Group.reset_column_information
    #for each group assign first admin with membership and assign as creator
    #could there be a Membership level of creator?
    Group.all.each do |group|
      if mship = Membership.find_by_group_id_and_access_level(group.id, 'admin')
        group.creator_id = mship.user_id
        group.save!
      elsif first_user = group.users.first
        group.creator_id = first_user.id
        group.save!
      else
        group.destroy
      end
    end
    change_column :groups, :creator_id, :int, :null => false
  end
end

class AddCreatorIdToGroups < ActiveRecord::Migration
  class Group < ActiveRecord::Base
    has_many :memberships,
      :conditions => {:access_level => Membership::MEMBER_ACCESS_LEVELS},
      :dependent => :destroy,
      :extend => GroupMemberships,
      :include => :user,
      :order => "LOWER(users.name)"
    has_many :membership_requests,
      :conditions => {:access_level => 'request'},
      :class_name => 'Membership',
      :dependent => :destroy
    has_many :admin_memberships,
      :conditions => {:access_level => 'admin'},
      :class_name => 'Membership',
      :dependent => :destroy
    has_many :users, :through => :memberships # TODO: rename to members
  end

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

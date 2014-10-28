class PopulateGroupCreator < ActiveRecord::Migration
  #def change
    ##for each group assign first admin with membership and assign as creator
    ##could there be a Membership level of creator?
    #Group.includes(:memberships).find_each(batch_size: 100) do |group|
      #if admin = group.memberships.where(admin: true).first
        #group.creator_id = admin.user_id
        #group.save!
      #elsif member = group.memberships.first
        #group.creator_id = member.user_id
        #group.save!
      #end
    #end
  #end
end

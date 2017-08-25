class RemoveIdentityIdFromGroups < ActiveRecord::Migration
  def change
    # Group.joins(:community).where.not("communities.identity_id": nil).each do |group|
    #   group.group_identities.create(identity_id: group.community.identity_id)
    # end
    remove_column :group_identities, :channel_name
    remove_column :group_identities, :channel_id
    add_column :group_identities, :custom_fields, :jsonb, default: {}, null: false
  end
end

class Simple::GroupSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id,
             :key,
             :handle,
             :name,
             :full_name,
             :type,
             :created_at,
             :creator_id,
             :is_visible_to_public,
             :announcement_recipients_count,
             :memberships_count,
             :invitations_count,
             :pending_invitations_count,
             :membership_granted_upon
end

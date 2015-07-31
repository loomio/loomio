class DiscussionSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id,
             :key,
             :title,
             :description,
             :last_item_at,
             :last_comment_at,
             :last_activity_at,
             :created_at,
             :updated_at,
             :items_count,
             :salient_items_count,
             :comments_count,
             :private,
             :archived_at,
             :created_at,
             :updated_at,
             :first_sequence_id,
             :last_sequence_id,
             :visible_on_dashboard

  has_one :author, serializer: UserSerializer, root: 'users'
  has_one :group, serializer: GroupSerializer, root: 'groups'
  has_one :active_proposal, serializer: MotionSerializer, root: 'proposals'

  def author
    object.author
  end

  def active_proposal
    object.current_motion
  end

  def visible_on_dashboard
    scope[:visible_on_dashboard]
  end

  def filter(keys)
    keys.delete(:active_proposal) unless object.current_motion.present?
    keys
  end

  def scope
    super || {}
  end
end

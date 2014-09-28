class DiscussionSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id,
             :key,
             :title,
             :description,
             :created_at,
             :updated_at,
             :items_count,
             :comments_count

  has_one :current_user, serializer: UserSerializer, root: 'users'
  has_one :author, serializer: UserSerializer, root: 'users'
  has_one :active_proposal, serializer: MotionSerializer, root: :proposals
  has_many :events, serializer: EventSerializer
  has_many :proposals, serializer: MotionSerializer

  def author
    object.author
  end
  
  def events
    object.items
  end

  def proposals
    object.motions
  end

  def active_proposal
    object.current_motion
  end

  def current_user
    scope
  end

  def filter(keys)
    keys.delete(:active_proposal) unless object.current_motion.present?
    keys
  end
end

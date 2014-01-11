class DiscussionSerializer < ActiveModel::Serializer
  attributes :id,
             :title,
             :description,
             :created_at,
             :updated_at,
             :items_count,
             :comments_count,
             :relationships

  has_one :current_user, serializer: AuthorSerializer, root: 'authors'
  has_one :author, serializer: AuthorSerializer
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

  def relationships
    {
      current_user: {foreign_key: 'current_user_id', collection: 'users'},
      author: { foreign_key: 'author_id', collection: 'authors' },
      active_proposal: { foreign_key: 'active_proposal_id', collection: 'proposals' },
      events: { foreign_key: 'event_ids', collection: 'events', type: 'list'},
      proposals: { foreign_key: 'proposal_ids', collection: 'proposals', type: 'list'}
    }
  end

  def filter(keys)
    keys.delete(:active_proposal) unless object.current_motion.present?
    keys
  end
end

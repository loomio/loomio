class DiscussionSerializer < ActiveModel::Serializer
  attributes :id,
             :title,
             :description,
             :created_at,
             :updated_at,
             :items_count,
             :comments_count

  has_one :current_user, serializer: AuthorSerializer
  has_one :author, serializer: AuthorSerializer
  has_one :active_proposal, serializer: MotionSerializer
  has_many :events

  def events
    object.items
  end

  def active_proposal
    object.current_motion
  end

  def current_user
    scope
  end

end

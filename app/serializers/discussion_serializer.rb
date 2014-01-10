class DiscussionSerializer < ActiveModel::Serializer
  attributes :id,
             :title,
             :description,
             :created_at,
             :updated_at,
             :items_count,
             :comments_count,
             :proposal,
             :current_user


  has_one :author
  has_many :events

  def proposal
    object.current_proposal
  end

  def current_user
    scope
  end

end

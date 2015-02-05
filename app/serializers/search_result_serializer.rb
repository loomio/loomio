class SearchResultSerializer < ActiveModel::Serializer
  attributes :priority, :query

  has_one  :discussion, serializer: SearchResults::DiscussionSerializer
  has_many :proposals,  serializer: SearchResults::MotionSerializer
  has_many :comments,   serializer: SearchResults::CommentSerializer

  def proposals
    object.motions
  end

end

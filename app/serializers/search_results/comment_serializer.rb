class SearchResults::CommentSerializer < SearchResults::BaseSerializer
  has_one :author, serializer: UserSerializer

  def author
    User.find_by(id: object.user_id)
  end
end

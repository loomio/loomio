class SearchResults::CommentSerializer < SearchResults::BaseSerializer
  attributes :author

  def author
    object.result.author_name
  end
end

class SearchResults::AuthorSerializer < SearchResults::BaseSerializer
  attributes :name, :avatarKind, :avatarInitials
end

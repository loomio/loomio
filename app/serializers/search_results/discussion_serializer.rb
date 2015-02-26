class SearchResults::DiscussionSerializer < SearchResults::BaseSerializer
  attributes :title, :created_at, :group_name, :group_full_name
end

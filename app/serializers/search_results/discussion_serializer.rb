class SearchResults::DiscussionSerializer < ApplicationSerializer
  attributes :title, :created_at, :group_name, :group_full_name, :key, :last_activity_at
end

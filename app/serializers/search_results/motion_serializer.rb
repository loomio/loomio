class SearchResults::MotionSerializer < SearchResults::BaseSerializer
  attributes :id, :name, :closing_at, :closed_at, :vote_counts
end

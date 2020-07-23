class PollOptionSerializer < ApplicationSerializer
  attributes :name, :display_name, :id, :poll_id, :priority, :color, :score_counts
end

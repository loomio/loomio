class PollOptionSerializer < ApplicationSerializer
  attributes :name, :id, :poll_id, :priority, :score_counts
end

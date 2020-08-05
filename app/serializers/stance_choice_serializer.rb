class StanceChoiceSerializer < ApplicationSerializer
  attributes :id, :score, :created_at, :stance_id, :rank, :rank_or_score, :poll_option_id
end

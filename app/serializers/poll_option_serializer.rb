class PollOptionSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :name, :display_name, :id, :poll_id, :priority, :color, :score_counts
end

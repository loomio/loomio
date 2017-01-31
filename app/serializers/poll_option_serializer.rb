class PollOptionSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :name, :id, :poll_id, :priority, :color
end

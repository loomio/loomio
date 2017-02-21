class StanceChoiceSerializer < ActiveModel::Serializer
  embed :ids, include: true

  attributes :id, :score, :created_at, :stance_id

  has_one :poll_option
end

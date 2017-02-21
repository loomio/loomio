class PollTemplateSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :name
  has_many :poll_options
end

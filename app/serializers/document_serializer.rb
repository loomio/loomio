class DocumentSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :title, :color, :url, :model_id, :model_type, :doctype, :attachment_id
end

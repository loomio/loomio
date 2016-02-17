class TranslationSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :translatable_id, :translatable_type, :fields, :language
end

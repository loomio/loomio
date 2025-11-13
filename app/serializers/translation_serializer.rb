class TranslationSerializer < ApplicationSerializer
  attributes :translatable_id, :translatable_type, :fields, :language, :id
end

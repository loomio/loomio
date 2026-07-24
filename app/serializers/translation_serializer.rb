class TranslationSerializer < ApplicationSerializer
  attributes :translatable_id, :translatable_type, :fields, :language, :id

  def translatable_id
    return object.translatable_id unless anonymous_stance?

    Stance.anonymous_id_for(poll_id: object.translatable.poll_id, stance_id: object.translatable_id)
  end

  private

  def anonymous_stance?
    object.translatable_type == 'Stance' && object.translatable&.poll&.anonymous?
  end
end

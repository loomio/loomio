class ModelErrorSerializer < ActiveModel::Serializer
  attributes :id, :messages

  def messages
    object.errors.full_messages
  end
end

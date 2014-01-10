class InvalidModelSerializer < ActiveModel::Serializer
  attributes :id, :error_messages

  def error_messages
    object.errors.full_messages
  end
end

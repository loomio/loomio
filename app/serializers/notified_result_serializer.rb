class NotifiedResultSerializer < ActiveModel::Serializer
  attributes :id, :type, :title, :subtitle, :icon_url

  def type
    object.class.to_s.demodulize
  end
end

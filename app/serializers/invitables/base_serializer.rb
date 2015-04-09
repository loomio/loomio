class Invitables::BaseSerializer < ActiveModel::Serializer
  attributes :id,
             :type,
             :name,
             :subtitle,
             :image

  def type
    object.class.to_s
  end

  def subtitle
    raise NotImplementedError.new
  end

  def image
    raise NotImplementedError.new
  end

end

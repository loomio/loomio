class Metadata::UserSerializer < ActiveModel::Serializer
  attributes :title, :description, :image_url
  root false

  def title
    object.name
  end

  def description
    object.username
  end

  def image_url
    object.avatar_url(:large)
  end

end

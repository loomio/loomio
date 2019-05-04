class Metadata::UserSerializer < ActiveModel::Serializer
  attributes :title, :description, :image_urls
  root false

  def title
    object.name
  end

  def description
    object.username
  end

  def image_urls
    [object.avatar_url(:large)]
  end
end

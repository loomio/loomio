class Metadata::GroupSerializer < ActiveModel::Serializer
  attributes :title, :description, :image_url
  root false

  def title
    object.full_name
  end

  def image_url
    object.logo.url
  end
end

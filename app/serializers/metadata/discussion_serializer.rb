class Metadata::DiscussionSerializer < ActiveModel::Serializer
  attributes :title, :description, :image_url
  root false

  def image_url
    object.group.logo.url
  end
end

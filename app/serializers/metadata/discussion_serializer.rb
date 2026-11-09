class Metadata::DiscussionSerializer < MetadataSerializer
  attributes :title, :description, :image_urls

  def description
    description_excerpt(object.description, object.description_format)
  end

  def image_urls
    absolute_image_urls(object.group&.cover_url, object.group&.logo_url)
  end
end

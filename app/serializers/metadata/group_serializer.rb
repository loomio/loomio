class Metadata::GroupSerializer < MetadataSerializer
  attributes :title, :description, :image_urls

  def title
    object.full_name
  end

  def description
    if object.is_visible_to_public?
      description_excerpt(object.description, object.description_format)
    end
  end

  def image_urls
    absolute_image_urls(object.cover_url, object.logo_url)
  end
end

class Metadata::GroupSerializer < MetadataSerializer
  attributes :title, :description, :image_urls

  def title
    object.full_name
  end

  def description
    if object.is_visible_to_public?
      render_plain_text(object.description, object.description_format)
    end
  end

  def image_urls
    [object.group.cover_photo.url, object.group.logo.url]
  end
end

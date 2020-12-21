class Metadata::PollSerializer < MetadataSerializer
  attributes :title, :description, :image_urls

  def title
    object.title
  end

  def description
    render_plain_text(object.details, object.details_format)
  end

  def image_urls
    object.group ? [object.group.cover_photo.url, object.group.logo.url] : []
  end
end

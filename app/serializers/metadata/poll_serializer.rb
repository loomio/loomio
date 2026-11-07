class Metadata::PollSerializer < MetadataSerializer
  attributes :title, :description, :image_urls

  def title
    object.title
  end

  def description
    description_excerpt(object.details, object.details_format)
  end

  def image_urls
    [object.group.cover_url, object.group.logo_url]
  end
end
